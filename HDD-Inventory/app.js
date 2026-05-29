'use strict';

const BASE_URL = (() => {
  const u = window.location.href.split('?')[0];
  return u.endsWith('/') ? u : u.replace(/[^/]+$/, '');
})();

const STORAGE_KEY = 'kryptonite_hdd_v1';

// ─── Seed data: 30 drives ──────────────────────────────────────────────────────
const SEED_DISKS = [
  { id:'DSK-26-001', nom:'APPLE SSD SM0128G Media',       type:'SSD NVMe',    cap:'121 Go',  dispo:'98 Go',   smart:'Sain',       test:'Passé',      partition:'GUID', enfants:2, dateAjout:'2026-05-01T00:00:00Z' },
  { id:'DSK-26-002', nom:'APPLE HDD ST2000LM007',          type:'HDD 5400rpm', cap:'2 To',    dispo:'1.4 To',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:3, dateAjout:'2026-05-01T00:00:00Z' },
  { id:'DSK-26-003', nom:'SAMSUNG 870 EVO 500 Go',         type:'SSD SATA',    cap:'500 Go',  dispo:'312 Go',  smart:'Sain',       test:'En cours',   partition:'GUID', enfants:1, dateAjout:'2026-05-02T00:00:00Z' },
  { id:'DSK-26-004', nom:'WD BLUE WD10EZEX 1 To',          type:'HDD 5400rpm', cap:'1 To',    dispo:'780 Go',  smart:'Prudence',   test:'En attente', partition:'MBR',  enfants:1, dateAjout:'2026-05-02T00:00:00Z' },
  { id:'DSK-26-005', nom:'SEAGATE BARRACUDA ST2000DM008',  type:'HDD 7200rpm', cap:'2 To',    dispo:'950 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:2, dateAjout:'2026-05-03T00:00:00Z' },
  { id:'DSK-26-006', nom:'CRUCIAL MX500 CT1000MX500SSD1',  type:'SSD SATA',    cap:'1 To',    dispo:'640 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:1, dateAjout:'2026-05-03T00:00:00Z' },
  { id:'DSK-26-007', nom:'WD BLACK WD4004FZWX 4 To',       type:'HDD 7200rpm', cap:'4 To',    dispo:'2.8 To',  smart:'Sain',       test:'En attente', partition:'GUID', enfants:1, dateAjout:'2026-05-04T00:00:00Z' },
  { id:'DSK-26-008', nom:'SEAGATE IRONWOLF ST4000VN008',   type:'HDD 7200rpm', cap:'4 To',    dispo:'3.2 To',  smart:'Sain',       test:'En attente', partition:'GUID', enfants:1, dateAjout:'2026-05-04T00:00:00Z' },
  { id:'DSK-26-009', nom:'SAMSUNG 860 PRO MZ-76P256',      type:'SSD SATA',    cap:'256 Go',  dispo:'180 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:2, dateAjout:'2026-05-05T00:00:00Z' },
  { id:'DSK-26-010', nom:'TOSHIBA MQ04ABF100 1 To',        type:'HDD 5400rpm', cap:'1 To',    dispo:'600 Go',  smart:'Prudence',   test:'Échec',      partition:'GUID', enfants:1, dateAjout:'2026-05-05T00:00:00Z' },
  { id:'DSK-26-011', nom:'WD RED WD20EFAX 2 To',           type:'HDD 5400rpm', cap:'2 To',    dispo:'1.1 To',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:2, dateAjout:'2026-05-06T00:00:00Z' },
  { id:'DSK-26-012', nom:'SAMSUNG 970 EVO MZ-V7E1T0',      type:'SSD NVMe',    cap:'1 To',    dispo:'820 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:1, dateAjout:'2026-05-06T00:00:00Z' },
  { id:'DSK-26-013', nom:'SEAGATE EXPANSION STEA2000400',  type:'HDD 5400rpm', cap:'2 To',    dispo:'1.8 To',  smart:'Sain',       test:'En attente', partition:'MBR',  enfants:1, dateAjout:'2026-05-07T00:00:00Z' },
  { id:'DSK-26-014', nom:'WD ELEMENTS WDBU6Y0010BBK',      type:'HDD 5400rpm', cap:'1 To',    dispo:'500 Go',  smart:'Sain',       test:'En attente', partition:'MBR',  enfants:1, dateAjout:'2026-05-07T00:00:00Z' },
  { id:'DSK-26-015', nom:'APPLE SSD AP0256M',               type:'SSD NVMe',    cap:'256 Go',  dispo:'210 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:3, dateAjout:'2026-05-08T00:00:00Z' },
  { id:'DSK-26-016', nom:'CRUCIAL BX500 CT480BX500SSD1',   type:'SSD SATA',    cap:'480 Go',  dispo:'320 Go',  smart:'Sain',       test:'En cours',   partition:'GUID', enfants:1, dateAjout:'2026-05-08T00:00:00Z' },
  { id:'DSK-26-017', nom:'SEAGATE ST3500418AS 500 Go',      type:'HDD 7200rpm', cap:'500 Go',  dispo:'120 Go',  smart:'Défaillant',  test:'Échec',      partition:'GUID', enfants:2, dateAjout:'2026-05-09T00:00:00Z' },
  { id:'DSK-26-018', nom:'WD BLUE SSD WDS250G2B0A',         type:'SSD SATA',    cap:'250 Go',  dispo:'200 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:1, dateAjout:'2026-05-09T00:00:00Z' },
  { id:'DSK-26-019', nom:'HITACHI HTS721010A9E630 1 To',    type:'HDD 7200rpm', cap:'1 To',    dispo:'450 Go',  smart:'Prudence',   test:'En cours',   partition:'GUID', enfants:1, dateAjout:'2026-05-10T00:00:00Z' },
  { id:'DSK-26-020', nom:'SAMSUNG 850 EVO MZ-75E500',       type:'SSD SATA',    cap:'500 Go',  dispo:'380 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:2, dateAjout:'2026-05-10T00:00:00Z' },
  { id:'DSK-26-021', nom:'WD RED PLUS WD40EFZX 4 To',       type:'HDD 7200rpm', cap:'4 To',    dispo:'3.6 To',  smart:'Sain',       test:'En attente', partition:'GUID', enfants:1, dateAjout:'2026-05-11T00:00:00Z' },
  { id:'DSK-26-022', nom:'SEAGATE BACKUP PLUS STDR4000200', type:'HDD 5400rpm', cap:'4 To',    dispo:'3.1 To',  smart:'Sain',       test:'En attente', partition:'MBR',  enfants:1, dateAjout:'2026-05-11T00:00:00Z' },
  { id:'DSK-26-023', nom:'SAMSUNG 980 PRO MZ-V8P2T0',       type:'SSD NVMe',    cap:'2 To',    dispo:'1.7 To',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:1, dateAjout:'2026-05-12T00:00:00Z' },
  { id:'DSK-26-024', nom:'TOSHIBA CANVIO HDTB410EK3AA',     type:'HDD 5400rpm', cap:'1 To',    dispo:'800 Go',  smart:'Sain',       test:'En attente', partition:'MBR',  enfants:1, dateAjout:'2026-05-12T00:00:00Z' },
  { id:'DSK-26-025', nom:'INTEL 545S SERIES SSDSC2KW512',   type:'SSD SATA',    cap:'512 Go',  dispo:'400 Go',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:1, dateAjout:'2026-05-13T00:00:00Z' },
  { id:'DSK-26-026', nom:'WD BLUE WD5000AAKX 500 Go',       type:'HDD 5400rpm', cap:'500 Go',  dispo:'280 Go',  smart:'Prudence',   test:'En cours',   partition:'GUID', enfants:1, dateAjout:'2026-05-13T00:00:00Z' },
  { id:'DSK-26-027', nom:'CORSAIR MP600 PRO CSSD-F1000',    type:'SSD NVMe',    cap:'1 To',    dispo:'900 Go',  smart:'Sain',       test:'En attente', partition:'GUID', enfants:1, dateAjout:'2026-05-14T00:00:00Z' },
  { id:'DSK-26-028', nom:'SEAGATE FIRECUDA ST2000LX001',    type:'HDD 7200rpm', cap:'2 To',    dispo:'1.5 To',  smart:'Sain',       test:'Passé',      partition:'GUID', enfants:2, dateAjout:'2026-05-14T00:00:00Z' },
  { id:'DSK-26-029', nom:'WD BLACK SN850 WDS100T1X0E',      type:'SSD NVMe',    cap:'1 To',    dispo:'850 Go',  smart:'Sain',       test:'En attente', partition:'GUID', enfants:1, dateAjout:'2026-05-15T00:00:00Z' },
  { id:'DSK-26-030', nom:'SAMSUNG T7 MU-PC1T0B 1 To USB',  type:'SSD SATA',    cap:'1 To',    dispo:'750 Go',  smart:'Sain',       test:'En attente', partition:'GUID', enfants:1, dateAjout:'2026-05-15T00:00:00Z' },
];

const SEED_AUDIT = {
  'DSK-26-001': [
    { ts:'2026-05-15T10:00:00Z', type:'CONNEXION', etat:'Sain',  notes:'Connexion initiale. Disque Apple interne PCIe NVMe. Détecté sur disk1. Table GUID. 2 volumes APFS. S.M.A.R.T. Utilitaire de Disque : Vérifié.' },
    { ts:'2026-05-20T14:30:00Z', type:'TEST',      etat:'Passé', notes:'Lecture séquentielle : 3 200 Mo/s. Écriture aléatoire 4K : 2 500 Mo/s. Aucun bloc défectueux détecté sur l\'intégralité des LBA. Résultat : PASSÉ.' },
  ],
  'DSK-26-002': [
    { ts:'2026-05-15T11:00:00Z', type:'CONNEXION', etat:'Sain',  notes:'Disque Apple HDD SATA interne. Détecté sur disk2. Table GUID. 3 conteneurs APFS montés sous /Volumes.' },
    { ts:'2026-05-18T09:00:00Z', type:'SMART',     etat:'Sain',  notes:'Rapport S.M.A.R.T. complet. Secteurs réalloués (attr 05) : 0. Heures de fonctionnement : 3 241 h. Température : 32°C. Santé globale : Sain.' },
    { ts:'2026-05-22T16:00:00Z', type:'TEST',      etat:'Passé', notes:'Test de surface intégral (2 To). Aucune erreur de lecture. Temps de réponse moyen : 14 ms. Débit lecture : 115 Mo/s. Résultat : PASSÉ.' },
  ],
  'DSK-26-003': [
    { ts:'2026-05-02T08:30:00Z', type:'CONNEXION', etat:'Sain',  notes:'SSD SATA Samsung 870 EVO. Port SATA-III port 0. Volume APFS unique. Firmware SVT01B1Q détecté.' },
    { ts:'2026-05-26T10:00:00Z', type:'TEST',      etat:'En cours', notes:'Test CrystalDiskMark en cours. Lecture séquentielle préliminaire : 548 Mo/s (conforme specs). Écriture en attente de finalisation.' },
  ],
  'DSK-26-004': [
    { ts:'2026-05-02T09:00:00Z', type:'CONNEXION', etat:'Prudence', notes:'WD Blue connecté via adaptateur USB-SATA. Pont contrôleur : JMicron JMS578. S.M.A.R.T. partiellement accessible. Partition MBR, 1 volume NTFS.' },
    { ts:'2026-05-10T11:30:00Z', type:'SMART',     etat:'Prudence', notes:'Attribut 190 (Airflow Temperature) = 54°C. Seuil constructeur : 45°C. Température critique. Refroidissement insuffisant via boîtier USB passif documenté.' },
  ],
  'DSK-26-010': [
    { ts:'2026-05-05T09:00:00Z', type:'CONNEXION', etat:'Prudence',   notes:'Connexion via boîtier USB 3.0 Orico. Limitation S.M.A.R.T. via pont USB documentée — données partielles uniquement. Formaté HFS+.' },
    { ts:'2026-05-12T14:00:00Z', type:'SMART',     etat:'Prudence',   notes:'Attr. 05 (Reallocated Sectors Count) = 4. Attr. 197 (Current Pending Sector) = 1. Surveillance renforcée requise. Ne pas utiliser pour données critiques.' },
    { ts:'2026-05-19T10:00:00Z', type:'TEST',      etat:'Échec',      notes:'Test de surface : 12 blocs défectueux localisés (LBA 0x0A3F2000–0x0A3F28FF). Disque dégradé à isoler. Récupération de données possible mais support non fiable.' },
  ],
  'DSK-26-017': [
    { ts:'2026-05-09T08:00:00Z', type:'CONNEXION', etat:'Défaillant', notes:'Bruit de clic répété au spin-up (click of death confirmé). Connexion SATA intermittente. Firmware non détectable sur première tentative.' },
    { ts:'2026-05-09T08:30:00Z', type:'SMART',     etat:'Défaillant', notes:'S.M.A.R.T. FAILURE IMMINENT. Attr. 05 = 512. Attr. 187 (Uncorrectable Errors) = 23. Attr. 01 (Raw Read Error Rate) : valeur brute hors plage.' },
    { ts:'2026-05-09T09:00:00Z', type:'TEST',      etat:'Échec',      notes:'Test abandonné à 3% du scan. Disque inaccessible de manière intermittente. Décision : destruction sécurisée ou récupération d\'urgence par prestataire.' },
  ],
  'DSK-26-019': [
    { ts:'2026-05-10T08:00:00Z', type:'CONNEXION', etat:'Prudence', notes:'Hitachi 7200rpm, 1 To. Boîtier USB passif. Pont JMicron — accès S.M.A.R.T. restreint. Volume HFS+ monté sur /Volumes/Untitled.' },
    { ts:'2026-05-20T13:00:00Z', type:'TEST',      etat:'En cours', notes:'Badblocks lancé (mode lecture seule). Progression : 38%. Secteurs à réponse lente (>= 2 000 ms) relevés sur plage 300-400 Go. Analyse en cours.' },
  ],
};

// ─── State ─────────────────────────────────────────────────────────────────────
let state = { disks: [], auditLog: {} };
let currentDiskId = null;

// ─── Persistence ───────────────────────────────────────────────────────────────
function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const saved = JSON.parse(raw);
      state.disks    = saved.disks    || SEED_DISKS;
      state.auditLog = saved.auditLog || SEED_AUDIT;
    } else {
      state.disks    = SEED_DISKS;
      state.auditLog = SEED_AUDIT;
      saveState();
    }
  } catch (_) {
    state.disks    = SEED_DISKS;
    state.auditLog = SEED_AUDIT;
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

// ─── Routing ───────────────────────────────────────────────────────────────────
function getRouteId() {
  return new URLSearchParams(window.location.search).get('id');
}

// ─── Badge helpers ─────────────────────────────────────────────────────────────
function smartClass(s) {
  if (s === 'Sain')       return 'badge-ok';
  if (s === 'Prudence')   return 'badge-warn';
  if (s === 'Défaillant') return 'badge-err';
  return 'badge-muted';
}

function testClass(t) {
  if (t === 'Passé')      return 'badge-ok';
  if (t === 'En cours')   return 'badge-info';
  if (t === 'Échec')      return 'badge-err';
  return 'badge-muted';
}

function typeIcon(t) {
  if (t.includes('NVMe')) return '⚡';
  if (t.includes('SSD'))  return '▪';
  return '◉';
}

// ─── Stats bar ─────────────────────────────────────────────────────────────────
function renderStats() {
  const total = state.disks.length;
  const sain  = state.disks.filter(d => d.smart === 'Sain').length;
  const warn  = state.disks.filter(d => d.smart === 'Prudence').length;
  const fail  = state.disks.filter(d => d.smart === 'Défaillant').length;
  document.getElementById('stats').innerHTML = `
    <span class="stat"><span class="stat-val">${total}</span> Total</span>
    <span class="stat stat-ok"><span class="stat-val">${sain}</span> Sain</span>
    <span class="stat stat-warn"><span class="stat-val">${warn}</span> Prudence</span>
    <span class="stat stat-err"><span class="stat-val">${fail}</span> Défaillant</span>`;
}

// ─── Dashboard ─────────────────────────────────────────────────────────────────
function getFiltered() {
  const q     = (document.getElementById('search')?.value     || '').toLowerCase();
  const fType = document.getElementById('filterType')?.value  || '';
  const fSmart= document.getElementById('filterSmart')?.value || '';
  const fTest = document.getElementById('filterTest')?.value  || '';
  return state.disks.filter(d => {
    if (q      && !d.nom.toLowerCase().includes(q) && !d.id.toLowerCase().includes(q)) return false;
    if (fType  && d.type      !== fType)  return false;
    if (fSmart && d.smart     !== fSmart) return false;
    if (fTest  && d.test      !== fTest)  return false;
    return true;
  });
}

function applyFilters() { renderDashboard(); }

function renderDashboard() {
  const disks = getFiltered();
  const main  = document.getElementById('main');
  if (!disks.length) {
    main.innerHTML = '<div class="empty">Aucun disque ne correspond aux filtres.</div>';
    return;
  }
  main.innerHTML = `<div class="grid">${disks.map(d => `
    <a class="card" href="?id=${d.id}" onclick="navTo('${d.id}',event)">
      <div class="card-top">
        <span class="card-id">${d.id}</span>
        <span class="badge ${smartClass(d.smart)}">${d.smart}</span>
      </div>
      <div class="card-name">${typeIcon(d.type)} ${d.nom}</div>
      <div class="card-meta">
        <span class="meta-chip">${d.type}</span>
        <span class="meta-chip">${d.cap}</span>
        <span class="badge ${testClass(d.test)}">${d.test}</span>
      </div>
      <div class="card-bottom">
        <span class="text-muted">Partition : ${d.partition}</span>
        <span class="text-muted">Dispo : ${d.dispo}</span>
      </div>
    </a>`).join('')}</div>`;
}

// ─── Detail view ───────────────────────────────────────────────────────────────
function navTo(id, e) {
  if (e) e.preventDefault();
  history.pushState({}, '', `?id=${id}`);
  showDetail(id);
  window.scrollTo(0, 0);
}

function navHome() {
  history.pushState({}, '', window.location.pathname);
  document.getElementById('filters').style.display = '';
  renderStats();
  renderDashboard();
}

function showDetail(id) {
  const disk = state.disks.find(d => d.id === id);
  if (!disk) {
    document.getElementById('main').innerHTML = `<div class="empty">Disque introuvable : ${id}</div>`;
    return;
  }
  document.getElementById('filters').style.display = 'none';
  const log = (state.auditLog[id] || []).slice().reverse();
  const qrUrl = `${BASE_URL}?id=${id}`;

  document.getElementById('main').innerHTML = `
    <div class="detail">
      <div class="detail-header">
        <button class="btn-back" onclick="navHome()">← Tableau de bord</button>
        <div class="detail-title">
          <code class="card-id">${disk.id}</code>
          <h2>${typeIcon(disk.type)} ${disk.nom}</h2>
        </div>
        <button class="btn-add" onclick="openModal('${id}')">+ Audit</button>
      </div>

      <div class="detail-grid">
        <div class="info-panel">
          <h3>Informations</h3>
          <table class="info-table">
            <tr><td>Type</td><td>${disk.type}</td></tr>
            <tr><td>Capacité</td><td>${disk.cap}</td></tr>
            <tr><td>Disponible</td><td>${disk.dispo}</td></tr>
            <tr><td>Table de partition</td><td>${disk.partition}</td></tr>
            <tr><td>Volumes enfants</td><td>${disk.enfants}</td></tr>
            <tr><td>État S.M.A.R.T.</td><td><span class="badge ${smartClass(disk.smart)}">${disk.smart}</span></td></tr>
            <tr><td>État de test</td><td><span class="badge ${testClass(disk.test)}">${disk.test}</span></td></tr>
            <tr><td>Ajouté le</td><td>${new Date(disk.dateAjout).toLocaleDateString('fr-FR')}</td></tr>
          </table>
          <div class="qr-section">
            <h4>URL Jumeau numérique</h4>
            <code class="qr-url">${qrUrl}</code>
          </div>
        </div>

        <div class="audit-panel">
          <div class="audit-hdr">
            <h3>Journal d'audit <span class="count">(${log.length} entr${log.length !== 1 ? 'ées' : 'ée'})</span></h3>
          </div>
          <div class="timeline">
            ${log.length === 0
              ? '<div class="empty">Aucune entrée d\'audit pour ce disque.</div>'
              : log.map(e => `
              <div class="tl-item">
                <div class="tl-dot ${dotClass(e.type, e.etat)}"></div>
                <div class="tl-body">
                  <div class="tl-meta">
                    <span class="tl-type">${e.type}</span>
                    <span class="badge ${auditBadge(e.etat)}">${e.etat}</span>
                    <span class="tl-ts">${fmtTs(e.ts)}</span>
                  </div>
                  <p class="tl-notes">${esc(e.notes)}</p>
                </div>
              </div>`).join('')}
          </div>
        </div>
      </div>
    </div>`;
}

function dotClass(type, etat) {
  if (etat === 'Sain'  || etat === 'Passé')    return 'dot-ok';
  if (etat === 'Prudence' || etat === 'En cours') return 'dot-warn';
  if (etat === 'Défaillant' || etat === 'Échec')  return 'dot-err';
  return 'dot-info';
}

function auditBadge(etat) {
  if (etat === 'Sain'  || etat === 'Passé')    return 'badge-ok';
  if (etat === 'Prudence' || etat === 'En cours') return 'badge-warn';
  if (etat === 'Défaillant' || etat === 'Échec')  return 'badge-err';
  return 'badge-info';
}

function fmtTs(ts) {
  return new Date(ts).toLocaleString('fr-FR', {
    year:'numeric', month:'short', day:'numeric', hour:'2-digit', minute:'2-digit'
  });
}

function esc(s) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// ─── Modal ─────────────────────────────────────────────────────────────────────
function openModal(id) {
  currentDiskId = id;
  document.getElementById('modal').classList.remove('hidden');
  document.getElementById('auditNotes').focus();
}

function closeModal() {
  document.getElementById('modal').classList.add('hidden');
  document.getElementById('auditForm').reset();
  currentDiskId = null;
}

function submitAudit(e) {
  e.preventDefault();
  if (!currentDiskId) return;

  const entry = {
    ts:    new Date().toISOString(),
    type:  document.getElementById('auditType').value,
    etat:  document.getElementById('auditEtat').value,
    notes: document.getElementById('auditNotes').value.trim(),
  };

  if (!state.auditLog[currentDiskId]) state.auditLog[currentDiskId] = [];
  state.auditLog[currentDiskId].push(entry);

  const disk = state.disks.find(d => d.id === currentDiskId);
  if (disk) {
    if (entry.type === 'SMART' && ['Sain','Prudence','Défaillant'].includes(entry.etat))
      disk.smart = entry.etat;
    if (entry.type === 'TEST'  && ['Passé','En cours','Échec'].includes(entry.etat))
      disk.test  = entry.etat;
  }

  saveState();
  closeModal();
  showDetail(currentDiskId);
  renderStats();
}

// ─── CSV Export (Katasymbol format) ───────────────────────────────────────────
function exportCSV() {
  const headers = 'ID,NOM,SMART,TEST,TYPE,CAPACITE,DISPONIBLE,ENFANTS,PARTITION,URL_QR';
  const rows = state.disks.map(d =>
    [d.id, `"${d.nom}"`, d.smart, d.test, d.type, d.cap, d.dispo, d.enfants, d.partition,
     `"${BASE_URL}?id=${d.id}"`].join(',')
  );
  const csv   = '﻿' + [headers, ...rows].join('\r\n');
  const blob  = new Blob([csv], { type: 'text/csv;charset=utf-8' });
  const a     = Object.assign(document.createElement('a'), {
    href: URL.createObjectURL(blob),
    download: `kryptonite_katasymbol_${new Date().toISOString().slice(0,10)}.csv`,
  });
  a.click();
  URL.revokeObjectURL(a.href);
}

// ─── Init ──────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  loadState();
  renderStats();
  const id = getRouteId();
  if (id) {
    document.getElementById('filters').style.display = 'none';
    showDetail(id);
  } else {
    renderDashboard();
  }
});

window.addEventListener('popstate', () => {
  const id = getRouteId();
  renderStats();
  if (id) {
    document.getElementById('filters').style.display = 'none';
    showDetail(id);
  } else {
    document.getElementById('filters').style.display = '';
    renderDashboard();
  }
});
