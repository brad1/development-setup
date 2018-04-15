from command_class import ShellCommand

def main(): 
  asdf = ShellCommand("grep -r 'main' .") 
  asdf.execute()


if __name__ == '__main__': 
  main() 
