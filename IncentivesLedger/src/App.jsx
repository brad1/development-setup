import React, { useMemo, useState } from 'react';
import { actors, aiAudits, methodology, organizations, sources, stories } from './data/incentivesLedger';

const tiers = ['All tiers', 'Major Players', 'Minor Players', 'Other'];
const routeButtons = [
  ['home', 'Home'],
  ['roster', '3000 Tyrants'],
  ['profile', 'Actor Profile'],
  ['incentives', 'The Incentives File'],
  ['methodology', 'Methodology'],
  ['sources', 'Source Ledger'],
  ['audit', 'AI Audit Log'],
];

const orgById = Object.fromEntries(organizations.map((org) => [org.id, org]));
const actorById = Object.fromEntries(actors.map((actor) => [actor.id, actor]));
const sourceById = Object.fromEntries(sources.map((source) => [source.id, source]));
const auditById = Object.fromEntries(aiAudits.map((audit) => [audit.id, audit]));

function tierClass(tier) {
  if (tier === 'Major Players') return 'major';
  if (tier === 'Minor Players') return 'minor';
  return 'other';
}

function InfluenceBadge({ tier }) {
  return <span className={`badge ${tierClass(tier)}`}>{tier}</span>;
}

function ConfidenceBadge({ score }) {
  return (
    <span className="badge confidence" style={{ '--score': `${score}%` }}>
      {score}% confidence
    </span>
  );
}

function Header({ route, setRoute }) {
  return (
    <header className="site-header">
      <div className="header-inner">
        <button className="brand" onClick={() => setRoute('home')} aria-label="Incentives Ledger home">
          <span className="brand-mark">Incentives Ledger</span>
          <span className="brand-kicker">Incentives before ideology</span>
        </button>
        <nav className="nav" aria-label="Primary navigation">
          {routeButtons.map(([key, label]) => (
            <button key={key} className={route === key ? 'active' : ''} onClick={() => setRoute(key)}>
              {label}
            </button>
          ))}
        </nav>
      </div>
    </header>
  );
}

function SectionHeading({ eyebrow, title, children }) {
  return (
    <div className="section-heading">
      <div>
        <div className="eyebrow">{eyebrow}</div>
        <h2>{title}</h2>
      </div>
      {children}
    </div>
  );
}

function ActorCard({ actor, setSelectedActorId, setRoute }) {
  return (
    <button
      className="actor-card"
      onClick={() => {
        setSelectedActorId(actor.id);
        setRoute('profile');
      }}
    >
      <div className="card-meta">
        <InfluenceBadge tier={actor.tier} />
        <ConfidenceBadge score={actor.confidenceScore} />
      </div>
      <h3>{actor.name}</h3>
      <p><strong>{actor.role}</strong></p>
      <p>{actor.influenceSummary}</p>
      <div className="card-orgs">
        {actor.organizations.map((orgId) => <span className="org-pill" key={orgId}>{orgById[orgId]?.name}</span>)}
      </div>
    </button>
  );
}

function EvidenceBox({ sourceId }) {
  const source = sourceById[sourceId];
  if (!source) return null;
  return (
    <article className="evidence-box">
      <strong>{source.title}</strong>
      <span className="quality">{source.quality} · reliability {source.reliability}%</span>
      <p>{source.notes}</p>
    </article>
  );
}

function SourceLedgerEntry({ source }) {
  return (
    <article className="source-entry">
      <header>
        <div>
          <h3>{source.title}</h3>
          <p>{source.outlet}</p>
        </div>
        <span className="badge">{source.date}</span>
      </header>
      <p><span className="quality">{source.quality}</span> · reliability score {source.reliability}%</p>
      <p>{source.notes}</p>
    </article>
  );
}

function AIAuditEntry({ audit }) {
  return (
    <article className="audit-entry">
      <div className="card-meta">
        <span className="badge">{audit.date}</span>
        <span className="badge">AI involvement tracked</span>
      </div>
      <h3>{audit.modelUse}</h3>
      <p><strong>Human review:</strong> {audit.humanReview}</p>
      <p><strong>Known risk:</strong> {audit.risk}</p>
    </article>
  );
}

function WeeklyIssueCard({ story, setSelectedActorId, setRoute }) {
  return (
    <article className="weekly-card">
      <header>
        <div>
          <div className="eyebrow">Weekly issue · {story.published}</div>
          <h3>{story.title}</h3>
        </div>
        <button
          className="secondary-action"
          onClick={() => {
            setSelectedActorId(story.subjectId);
            setRoute('profile');
          }}
        >
          Open dossier
        </button>
      </header>
      <p>{story.deck}</p>
    </article>
  );
}

function RelationshipGraph({ actor, setSelectedActorId }) {
  return (
    <section className="panel relationship-graph" aria-label="Relationship graph">
      <div className="eyebrow">Relationship graph</div>
      <h3>{actor.name}</h3>
      {actor.relationships.map((relationship) => {
        const related = actorById[relationship.actorId];
        return (
          <div key={`${actor.id}-${relationship.actorId}`}>
            <div className="graph-line" />
            <button className="graph-node" onClick={() => related && setSelectedActorId(related.id)}>
              <strong>{related?.name ?? relationship.actorId}</strong>
              <span>{relationship.type}</span>
              <div><span className="badge">{relationship.strength} evidence</span></div>
            </button>
          </div>
        );
      })}
    </section>
  );
}

function Home({ setRoute, setSelectedActorId }) {
  const counts = tiers.slice(1).map((tier) => [tier, actors.filter((actor) => actor.tier === tier).length]);
  return (
    <>
      <section className="hero">
        <div className="hero-card">
          <div className="eyebrow">Proof of concept · fictional data only</div>
          <h1>Track incentives, not tribes.</h1>
          <p className="hero-copy">
            Incentives Ledger is an investigative dossier prototype for mapping influential actors, public claims,
            source quality, conflicts, blind spots, and AI-assisted research decisions without turning uncertainty
            into accusation.
          </p>
          <div className="hero-actions">
            <button className="primary-action" onClick={() => setRoute('roster')}>Browse 3000 Tyrants</button>
            <button className="secondary-action" onClick={() => setRoute('incentives')}>Read sample issue</button>
          </div>
        </div>
        <aside className="panel">
          <div className="eyebrow">Roster tiers</div>
          <div className="stats-strip">
            {counts.map(([tier, count]) => (
              <div className="stat" key={tier}><strong>{count}</strong><span>{tier}</span></div>
            ))}
          </div>
          <p>The structure is designed so fictional actors can be replaced with real-world records later without changing the application model.</p>
        </aside>
      </section>
      <SectionHeading eyebrow="Recurring departments" title="What readers can inspect" />
      <div className="grid three">
        <div className="panel"><h3>Actor dossiers</h3><p>Profiles separate roles, incentives, public claims, notable actions, relationships, blind spots, sources, confidence, and AI audit history.</p></div>
        <div className="panel"><h3>Source quality</h3><p>Every source gets a type, reliability score, and notes about what the source can and cannot prove.</p></div>
        <div className="panel"><h3>Recurring files</h3><p>The Incentives File uses a repeatable format: subject, interests, question, evidence, unknowns, and non-accusatory verdict.</p></div>
      </div>
      <SectionHeading eyebrow="Major players" title="Start with the highest influence nodes" />
      <div className="actor-grid">
        {actors.filter((actor) => actor.tier === 'Major Players').map((actor) => (
          <ActorCard key={actor.id} actor={actor} setRoute={setRoute} setSelectedActorId={setSelectedActorId} />
        ))}
      </div>
    </>
  );
}

function Roster({ setRoute, setSelectedActorId }) {
  const [query, setQuery] = useState('');
  const [tier, setTier] = useState('All tiers');
  const [sort, setSort] = useState('confidence');
  const filteredActors = useMemo(() => {
    const normalized = query.toLowerCase();
    return actors
      .filter((actor) => tier === 'All tiers' || actor.tier === tier)
      .filter((actor) => [actor.name, actor.role, actor.influenceSummary, ...actor.knownIncentives].join(' ').toLowerCase().includes(normalized))
      .sort((a, b) => sort === 'name' ? a.name.localeCompare(b.name) : b.confidenceScore - a.confidenceScore);
  }, [query, tier, sort]);
  return (
    <>
      <SectionHeading eyebrow="3000 Tyrants" title="Fictional roster prototype">
        <span className="badge">{filteredActors.length} visible entries</span>
      </SectionHeading>
      <div className="roster-tools">
        <input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search actors, roles, incentives" aria-label="Search roster" />
        <select value={tier} onChange={(event) => setTier(event.target.value)} aria-label="Filter by tier">
          {tiers.map((tierName) => <option key={tierName}>{tierName}</option>)}
        </select>
        <select value={sort} onChange={(event) => setSort(event.target.value)} aria-label="Sort roster">
          <option value="confidence">Sort by confidence</option>
          <option value="name">Sort by name</option>
        </select>
      </div>
      <div className="actor-grid">
        {filteredActors.map((actor) => <ActorCard key={actor.id} actor={actor} setRoute={setRoute} setSelectedActorId={setSelectedActorId} />)}
      </div>
    </>
  );
}

function ActorProfile({ selectedActorId, setSelectedActorId }) {
  const actor = actorById[selectedActorId] ?? actors[0];
  return (
    <>
      <div className="profile-title">
        <div className="card-meta"><InfluenceBadge tier={actor.tier} /><ConfidenceBadge score={actor.confidenceScore} /><span className="badge">Updated {actor.lastUpdated}</span></div>
        <h1>{actor.name}</h1>
        <p className="hero-copy">{actor.role}</p>
      </div>
      <div className="profile-layout">
        <section className="panel">
          <dl className="dossier-table">
            <DossierRow label="Organizations"><PillList items={actor.organizations.map((orgId) => orgById[orgId]?.name)} /></DossierRow>
            <DossierRow label="Influence summary">{actor.influenceSummary}</DossierRow>
            <DossierRow label="Known incentives"><PillList items={actor.knownIncentives} /></DossierRow>
            <DossierRow label="Public claims"><PillList items={actor.publicClaims} /></DossierRow>
            <DossierRow label="Notable actions"><PillList items={actor.notableActions} /></DossierRow>
            <DossierRow label="Known blind spots"><PillList items={actor.knownBlindSpots} /></DossierRow>
          </dl>
        </section>
        <RelationshipGraph actor={actor} setSelectedActorId={setSelectedActorId} />
      </div>
      <SectionHeading eyebrow="Evidence" title="Source ledger for this dossier" />
      <div className="grid three">{actor.sourceLedger.map((sourceId) => <EvidenceBox key={sourceId} sourceId={sourceId} />)}</div>
      <SectionHeading eyebrow="AI audit log" title="Machine assistance and human review" />
      <div className="grid two">{actor.aiAuditLog.map((auditId) => <AIAuditEntry key={auditId} audit={auditById[auditId]} />)}</div>
    </>
  );
}

function DossierRow({ label, children }) {
  return <div className="dossier-row"><dt>{label}</dt><dd>{children}</dd></div>;
}

function PillList({ items }) {
  return <ul className="chip-list">{items.map((item) => <li key={item}>{item}</li>)}</ul>;
}

function IncentivesFile({ setRoute, setSelectedActorId }) {
  const featured = stories[0];
  return (
    <>
      <SectionHeading eyebrow="The Incentives File" title="A repeatable article format" />
      <article className="panel issue-body">
        <div className="eyebrow">Subject</div>
        <h1>{actorById[featured.subjectId].name}</h1>
        <p className="hero-copy">{featured.deck}</p>
        <div className="grid two">
          <div><h3>Known Interests</h3><PillList items={featured.knownInterests} /></div>
          <div><h3>Known Unknowns</h3><PillList items={featured.knownUnknowns} /></div>
        </div>
        <div className="callout"><p>Question: {featured.question}</p></div>
        <div>
          <h3>Evidence</h3>
          <div className="grid three">{featured.evidence.map((sourceId) => <EvidenceBox key={sourceId} sourceId={sourceId} />)}</div>
        </div>
        <div className="newsprint"><h3>Verdict</h3><p>{featured.verdict}</p><p>This framing encourages scrutiny of incentives without claiming hidden intent. Facts, interpretations, and unknowns remain visibly separated so readers can challenge the method.</p></div>
      </article>
      <SectionHeading eyebrow="Issue archive" title="Recurring dossiers" />
      <div className="grid three">{stories.map((story) => <WeeklyIssueCard key={story.id} story={story} setRoute={setRoute} setSelectedActorId={setSelectedActorId} />)}</div>
    </>
  );
}

function Methodology() {
  return (
    <>
      <SectionHeading eyebrow="Methodology" title="Rules for a non-accusatory newsroom" />
      <div className="grid two">
        <section className="panel">
          <h3>Operating requirements</h3>
          <ul className="method-list">{methodology.map((item) => <li key={item}>{item}</li>)}</ul>
        </section>
        <section className="panel">
          <h3>Data model discipline</h3>
          <p>Actors, organizations, sources, stories, relationships, confidence scores, and AI audit entries are independent records. That keeps the application ready for replacement data later.</p>
          <p>Confidence scores summarize source coverage and review status. They are not guilt scores, ideology scores, or proof of intent.</p>
        </section>
      </div>
    </>
  );
}

function Sources() {
  return (
    <>
      <SectionHeading eyebrow="Source Ledger" title="Evidence quality before narrative" />
      <div className="grid two">{sources.map((source) => <SourceLedgerEntry key={source.id} source={source} />)}</div>
    </>
  );
}

function AuditLog() {
  return (
    <>
      <SectionHeading eyebrow="AI Audit Log" title="What machines touched and what humans reviewed" />
      <div className="grid two">{aiAudits.map((audit) => <AIAuditEntry key={audit.id} audit={audit} />)}</div>
    </>
  );
}

export default function App() {
  const [route, setRoute] = useState('home');
  const [selectedActorId, setSelectedActorId] = useState('major-newspaper-baron');
  return (
    <div className="app-shell">
      <Header route={route} setRoute={setRoute} />
      <main>
        {route === 'home' && <Home setRoute={setRoute} setSelectedActorId={setSelectedActorId} />}
        {route === 'roster' && <Roster setRoute={setRoute} setSelectedActorId={setSelectedActorId} />}
        {route === 'profile' && <ActorProfile selectedActorId={selectedActorId} setSelectedActorId={setSelectedActorId} />}
        {route === 'incentives' && <IncentivesFile setRoute={setRoute} setSelectedActorId={setSelectedActorId} />}
        {route === 'methodology' && <Methodology />}
        {route === 'sources' && <Sources />}
        {route === 'audit' && <AuditLog />}
      </main>
      <footer className="footer">Incentives Ledger prototype. All actors, organizations, sources, and stories are fictional seed data.</footer>
    </div>
  );
}
