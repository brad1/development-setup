#include <stdio.h>
#include "filesys/inode.h"
#include <list.h>
#include <debug.h>
#include <round.h>
#include <string.h>
#include "filesys/free-map.h"
#include "filesys/filesys.h"
#include "threads/malloc.h"

//---------------- Additions to facilitate file growth  --------------------//

/* Index way over the 8mb limit, "null pointer" for block_sector_t */
#define  CHILD_NULL 0xffffffff
/* Number of blocks pointed to by an inode */
#define CHILD_COUNT 128
/* Identifies an inode. */
#define INODE_MAGIC 0x494e4f44
/* 2^23 */
#define eightMB 0x01000000

/* An inode stored in a block. Used to store indicies of other blocks. */
struct inode_disk
  {
    block_sector_t child[CHILD_COUNT];          /* Sector indices of child inodes */
  };

/* written before any of the other inodes. */
struct inode_metadata
  {
    block_sector_t root;
    off_t length;
    unsigned magic;
    uint32_t unused[125];
  };

struct inode;

bool is_full( struct inode_disk*);
void inode_disk_init( struct inode_disk* );
bool get_blocks( block_sector_t*, size_t, block_sector_t*, size_t );
bool expand_file( struct inode*, off_t newLength );

//--------------------------------------------------------------------------//


/* Returns the number of sectors to allocate for an inode SIZE
   bytes long. */
static inline size_t
bytes_to_sectors (off_t size)
{
  return DIV_ROUND_UP (size, BLOCK_SECTOR_SIZE);
}

/* In-memory inode. */
struct inode 
  {
    struct list_elem elem;              /* Element in inode list. */
    block_sector_t sector;              /* Sector number of disk location. */
    int open_cnt;                       /* Number of openers. */
    bool removed;                       /* True if deleted, false otherwise. */
    int deny_write_cnt;                 /* 0: writes ok, >0: deny writes. */
    struct inode_metadata data;             /* Inode content. */
  };

/* Returns the block device sector that contains byte offset POS
   within INODE.
   Returns -1 if INODE does not contain data for a byte at offset
   POS. */
static block_sector_t
byte_to_sector (const struct inode *inode, off_t pos) 
{
  ASSERT (inode != NULL);
  if( inode->data.length <= pos) {
    return -1;
  } 
  
  // find which numbered sector has this offset
  unsigned int sector_off = pos / BLOCK_SECTOR_SIZE;
  
  // find which indirect block references the dbl_indirect block
  unsigned int indirect_idx = sector_off / CHILD_COUNT;

  // find the index of the dbl_indirect block
  unsigned int dbl_indirect_idx = sector_off % CHILD_COUNT;
 
  block_sector_t direct_sector = inode->data.root;
  struct inode_disk direct;
  block_read( fs_device, direct_sector, &direct );

  block_sector_t indirect_sector = direct.child[indirect_idx];
  struct inode_disk indirect;
  block_read( fs_device, indirect_sector, &indirect );

  return indirect.child[dbl_indirect_idx];
}

/* List of open inodes, so that opening a single inode twice
   returns the same `struct inode'. */
static struct list open_inodes;

/* Initializes the inode module. */
void
inode_init (void) 
{
  list_init (&open_inodes);
}

/* Initializes an inode with LENGTH bytes of data and
   writes the new inode to sector SECTOR on the file system
   device.
   Returns true if successful.
   Returns false if memory or disk allocation fails. */
bool
inode_create (block_sector_t sector, off_t length)
{
  //printf("creating inode\n");
  ASSERT ( 0 <= length );
  struct inode_disk *direct = NULL;
  struct inode_metadata *metadata = NULL;

  /* If this assertion fails, the inode structure is not exactly
  one sector in size, and you should fix that. */
  ASSERT (sizeof *direct == BLOCK_SECTOR_SIZE);
  ASSERT (sizeof *metadata == BLOCK_SECTOR_SIZE);

  direct = calloc (1, sizeof *direct);
  metadata = calloc (1, sizeof *metadata);
  
  if ( direct != NULL && metadata != NULL )
    {
      //printf("calloc success\n");
      size_t num_sectors = bytes_to_sectors (length);
      size_t num_indirect = DIV_ROUND_UP( num_sectors, CHILD_COUNT ); 
      inode_disk_init(direct);
      metadata->length = length;
      metadata->magic = INODE_MAGIC;
       
      // store sector nums we are going to use
      block_sector_t *blocks = malloc( sizeof( block_sector_t) * num_sectors );
      block_sector_t *childs = malloc( sizeof( block_sector_t) * num_indirect );
      
      if( !get_blocks( blocks, num_sectors, childs, num_indirect ) ||
          !free_map_allocate(1, &metadata->root ) ) 
      {
        //printf("getblocks fail\n");
        free( blocks );
        free( childs );
        free(metadata);
        free(direct);
        return false;
      }

      block_write (fs_device, sector, metadata);
      
      // write these sector nums into the file structure.
      
      unsigned int i;
      unsigned int j;
      unsigned int sectors_done = 0;
      static char zeros[BLOCK_SECTOR_SIZE];

      
      // for each indirect block needed in root inode, assign a sector
      for( i = 0; i < num_indirect; i++ ) { 
         direct->child[i] = childs[i];
         struct inode_disk inode_indirect;
         inode_disk_init(&inode_indirect);
         // for each raw data block in inode_child, assign a sector.
         // assert that we run out of sectors on the last child.
         for( j = 0; j < CHILD_COUNT; j++ ) {
           inode_indirect.child[j] = blocks[sectors_done++];
           block_write( fs_device, inode_indirect.child[j], zeros );
           if( sectors_done == num_sectors ) {
             ASSERT( i+1 == num_indirect ) 
             break; 
           }
         }
         block_write( fs_device, childs[i], &inode_indirect );
      }
      block_write (fs_device, metadata->root, direct);
      //printf("finished buidling file\n");
      free( blocks );
      free( childs );
      free(direct);
      free(metadata);
    } else {
      //printf("calloc fail\n");
      free(direct);
      free(metadata);
      return false;
    }

  return true;
}

/* Reads an inode from SECTOR
   and returns a `struct inode' that contains it.
   Returns a null pointer if memory allocation fails. */
struct inode *
inode_open (block_sector_t sector)
{
  struct list_elem *e;
  struct inode *inode;

  /* Check whether this inode is already open. */
  for (e = list_begin (&open_inodes); e != list_end (&open_inodes);
       e = list_next (e)) 
    {
      inode = list_entry (e, struct inode, elem);
      if (inode->sector == sector) 
        {
          inode_reopen (inode);
          return inode; 
        }
    }

  /* Allocate memory. */
  inode = malloc (sizeof *inode);
  if (inode == NULL)
    return NULL;

  /* Initialize. */
  list_push_front (&open_inodes, &inode->elem);
  inode->sector = sector;
  inode->open_cnt = 1;
  inode->deny_write_cnt = 0;
  inode->removed = false;
  block_read (fs_device, inode->sector, &inode->data);
  return inode;
}

/* Reopens and returns INODE. */
struct inode *
inode_reopen (struct inode *inode)
{
  if (inode != NULL)
    inode->open_cnt++;
  return inode;
}

/* Returns INODE's inode number. */
block_sector_t
inode_get_inumber (const struct inode *inode)
{
  return inode->sector;
}

/* Closes INODE and writes it to disk.
   If this was the last reference to INODE, frees its memory.
   If INODE was also a removed inode, frees its blocks. */
void
inode_close (struct inode *inode) 
{
  /* Ignore null pointer. */
  if (inode == NULL)
    return;

  /* Release resources if this was the last opener. */
  if (--inode->open_cnt == 0)
    {
      /* Remove from inode list and release lock. */
      list_remove (&inode->elem);
 
      /* Deallocate blocks if removed. */
      if (inode->removed) 
        {
          // release metadata
          free_map_release (inode->sector, 1);
         
          // get root of file
          block_sector_t direct_sector = inode->data.root;
          struct inode_disk direct;
          block_read( fs_device, direct_sector, &direct );

          // release indirect and dbl_indirect blocks
          int i = 0;
          int j = 0;
          while( direct.child[i] != CHILD_NULL && i < CHILD_COUNT ) {
            // get indirect block
            block_sector_t indirect_sector = direct.child[i];
            struct inode_disk indirect;
            block_read( fs_device, indirect_sector, &indirect );
            // iterate through it
            while( indirect.child[j] != CHILD_NULL && j < CHILD_COUNT ) {
              //get dbl_indirect block
              block_sector_t dbl_indirect_sector = indirect.child[j];
              struct inode_disk dbl_indirect;
              block_read( fs_device, dbl_indirect_sector, &dbl_indirect );
              free_map_release( dbl_indirect_sector, 1 );
            }
            free_map_release( indirect_sector, 1 );
          }
          
          // release direct block
          free_map_release( direct_sector, 1 );
        }

      free (inode); 
    }
}

/* Marks INODE to be deleted when it is closed by the last caller who
   has it open. */
void
inode_remove (struct inode *inode) 
{
  ASSERT (inode != NULL);
  inode->removed = true;
}

/* Reads SIZE bytes from INODE into BUFFER, starting at position OFFSET.
   Returns the number of bytes actually read, which may be less
   than SIZE if an error occurs or end of file is reached. */
off_t
inode_read_at (struct inode *inode, void *buffer_, off_t size, off_t offset) 
{
  uint8_t *buffer = buffer_;
  off_t bytes_read = 0;
  uint8_t *bounce = NULL;

  while (size > 0) 
    {
      /* Disk sector to read, starting byte offset within sector. */
      block_sector_t sector_idx = byte_to_sector (inode, offset);
      int sector_ofs = offset % BLOCK_SECTOR_SIZE;

      /* Bytes left in inode, bytes left in sector, lesser of the two. */
      off_t inode_left = inode_length (inode) - offset;
      int sector_left = BLOCK_SECTOR_SIZE - sector_ofs;
      int min_left = inode_left < sector_left ? inode_left : sector_left;

      /* Number of bytes to actually copy out of this sector. */
      int chunk_size = size < min_left ? size : min_left;
      if (chunk_size <= 0)
        break;

      if (sector_ofs == 0 && chunk_size == BLOCK_SECTOR_SIZE)
        {
          /* Read full sector directly into caller's buffer. */
          block_read (fs_device, sector_idx, buffer + bytes_read);
        }
      else 
        {
          /* Read sector into bounce buffer, then partially copy
             into caller's buffer. */
          if (bounce == NULL) 
            {
              bounce = malloc (BLOCK_SECTOR_SIZE);
              if (bounce == NULL)
                break;
            }
          block_read (fs_device, sector_idx, bounce);
          memcpy (buffer + bytes_read, bounce + sector_ofs, chunk_size);
        }
      
      /* Advance. */
      size -= chunk_size;
      offset += chunk_size;
      bytes_read += chunk_size;
    }
  free (bounce);

  return bytes_read;
}

/* Writes SIZE bytes from BUFFER into INODE, starting at OFFSET.
   Returns the number of bytes actually written, which may be
   less than SIZE if end of file is reached or an error occurs.
   (Normally a write at end of file would extend the inode, but
   growth is not yet implemented.) */
off_t
inode_write_at (struct inode *inode, const void *buffer_, off_t size,
                off_t offset) 
{
  const uint8_t *buffer = buffer_;
  off_t bytes_written = 0;
  uint8_t *bounce = NULL;

  bool grown = false;
  // compare length of file with size needed for write
  if( inode->data.length < offset + size ) {
    expand_file( inode, offset + size );
    grown = true;
  }

  if (inode->deny_write_cnt)
    return 0;

  while (size > 0) 
    {
      /* Sector to write, starting byte offset within sector. */
      block_sector_t sector_idx = byte_to_sector (inode, offset);
      int sector_ofs = offset % BLOCK_SECTOR_SIZE;

      /* Bytes left in inode, bytes left in sector, lesser of the two. */
      off_t inode_left = inode_length (inode) - offset;
      int sector_left = BLOCK_SECTOR_SIZE - sector_ofs;
      int min_left = inode_left < sector_left ? inode_left : sector_left;

      /* Number of bytes to actually write into this sector. */
      int chunk_size = size < min_left ? size : min_left;
      if (chunk_size <= 0)
        break;

      if (sector_ofs == 0 && chunk_size == BLOCK_SECTOR_SIZE)
        {
          /* Write full sector directly to disk. */
          block_write (fs_device, sector_idx, buffer + bytes_written);
        }
      else 
        {
          /* We need a bounce buffer. */
          if (bounce == NULL) 
            {
              bounce = malloc (BLOCK_SECTOR_SIZE);
              if (bounce == NULL)
                break;
            }

          /* If the sector contains data before or after the chunk
             we're writing, then we need to read in the sector
             first.  Otherwise we start with a sector of all zeros. */
          if (sector_ofs > 0 || chunk_size < sector_left) 
            block_read (fs_device, sector_idx, bounce);
          else
            memset (bounce, 0, BLOCK_SECTOR_SIZE);
          memcpy (bounce + sector_ofs, buffer + bytes_written, chunk_size);
          block_write (fs_device, sector_idx, bounce);
        }

      /* Advance. */
      size -= chunk_size;
      offset += chunk_size;
      bytes_written += chunk_size;
    }
  free (bounce);

  return bytes_written;
}

/* Disables writes to INODE.
   May be called at most once per inode opener. */
void
inode_deny_write (struct inode *inode) 
{
  inode->deny_write_cnt++;
  ASSERT (inode->deny_write_cnt <= inode->open_cnt);
}

/* Re-enables writes to INODE.
   Must be called once by each inode opener who has called
   inode_deny_write() on the inode, before closing the inode. */
void
inode_allow_write (struct inode *inode) 
{
  ASSERT (inode->deny_write_cnt > 0);
  ASSERT (inode->deny_write_cnt <= inode->open_cnt);
  inode->deny_write_cnt--;
}

/* Returns the length, in bytes, of INODE's data. */
off_t
inode_length (const struct inode *inode)
{
  return inode->data.length;
}


// check to see if inode is full
bool is_full( struct inode_disk *pidc )
{
  return !(pidc->child[CHILD_COUNT-1] == CHILD_NULL);
}

// setup a new inode_disk_child
void inode_disk_init( struct inode_disk *pidc )
{
  // set all children to NULL
  int i;
  for( i = 0; i < CHILD_COUNT; i++ ) {
    pidc->child[i] = CHILD_NULL; 
  } 
}

// fills buffers with sector indicies.
// returns false if operation fails.
bool get_blocks( block_sector_t* buffa, size_t sizea, 
                 block_sector_t* buffb, size_t sizeb ) 
{
  unsigned int i;
  for( i = 0; i < sizea; i++ ) {
    if( !free_map_allocate(1, &buffa[i] ) ) {
      return false;
    }
  }

  for( i = 0; i < sizeb; i++ ) {
    if( !free_map_allocate(1, &buffb[i] ) ) {
      return false;
    }
  }

  return true;  
}

bool expand_file( struct inode* inode, off_t newLength ) {
 
  // get metadata sector
  block_sector_t meta_sector = inode->sector;
  struct inode_metadata meta;
  block_read( fs_device, meta_sector, &meta );
 
  // check for valid sizes 
  ASSERT( meta.length <  eightMB );
  ASSERT( meta.length <  newLength);
  ASSERT( newLength   <= eightMB );

  // get direct block from filesys
  block_sector_t direct_sector = meta.root;
  struct inode_disk direct;
  block_read(fs_device, direct_sector, &direct );

  // calculate how many new blocks to allocate
  off_t OldNumSectors = bytes_to_sectors(meta.length);
  off_t OldNumIndirect = DIV_ROUND_UP( OldNumSectors, CHILD_COUNT );
  off_t NewNumSectors = bytes_to_sectors( newLength );
  off_t NewNumIndirect = DIV_ROUND_UP( NewNumSectors, CHILD_COUNT );
  off_t BlocksToAdd = NewNumSectors - OldNumSectors;
  off_t indirectsToAdd = NewNumIndirect - OldNumIndirect;

  // file expanded by less than a block, make no further changes
  if( BlocksToAdd == 0 ) {
    meta.length = newLength;
    block_write( fs_device, meta_sector, &meta );
    inode->data.length = newLength;
    return true;
  }

  // Allocate all the new sectors we need.
  block_sector_t *dblIndirects
    = malloc( sizeof( block_sector_t ) * BlocksToAdd );
  block_sector_t *indirects
    = malloc( sizeof( block_sector_t ) * indirectsToAdd );

  if(!get_blocks( indirects, indirectsToAdd, dblIndirects, BlocksToAdd )) {
    free( dblIndirects );
    return false;
  }

  /* --  fills in sectors for the indirect blocks -- */
  off_t indirect_idx = OldNumSectors/CHILD_COUNT;
  off_t i;

  // calculate index of first dbl indirect block to be added.
  // read in an indirect block and fill it if it isn't already.
  
  off_t indirectsAdded = 0;
  off_t dblIndirect_idx = OldNumSectors % 128;
  struct inode_disk indirect;
  inode_disk_init( &indirect );
  if( 0 < dblIndirect_idx ) { 
    block_read( fs_device, direct.child[indirect_idx], &indirect );
  } else {
    direct.child[indirect_idx] = indirects[indirectsAdded++];  
  }

  // fill in sectors for double indirect blocks
  static char zeros[BLOCK_SECTOR_SIZE];
  for( i = 0; i < BlocksToAdd; i++ ) {
    indirect.child[dblIndirect_idx++] = dblIndirects[i];
    block_write( fs_device, dblIndirects[i], zeros );
    if( dblIndirect_idx == 128 || i == BlocksToAdd-1 ) {
      dblIndirect_idx = 0;
      block_write(fs_device, direct.child[indirect_idx++], &indirect );
      if( indirectsAdded < indirectsToAdd  ) {
        direct.child[indirect_idx] = indirects[indirectsAdded++];
      }
      inode_disk_init( &indirect );
    }
  }

  ASSERT( indirectsAdded == indirectsToAdd );

  // write metadata and root blocks back to disk
  meta.length = newLength;
  block_write( fs_device, meta_sector, &meta );
  block_write( fs_device, meta.root, &direct );

  // update in-memory inode
  block_read( fs_device, meta_sector, &inode->data );
  free( dblIndirects );

  return true;
}
