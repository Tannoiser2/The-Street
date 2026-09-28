#!/usr/bin/env python3
"""La pagina del rapporto delle partite (registro 125).

    python3 tools/rapporto_html.py rapporto.json note.json > rapporto.html

`rapporto.json` viene da tools/rapporto_partite.py; `note.json` porta il
titolo della prova sul Lampo e le frasi di sintesi (scritte a mano dopo aver
letto i numeri). La pagina e' statica: i dati stanno dentro, il disegno lo fa
un piccolo script.
"""
import json, sys, html

dati = json.load(open(sys.argv[1], encoding="utf-8"))
note = json.load(open(sys.argv[2], encoding="utf-8")) if len(sys.argv) > 2 else {}

PAGINA = r"""<title>Strada delle Ere, partite simulate</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Alegreya+SC:wght@500;700&family=Alegreya+Sans:ital,wght@0,400;0,500;0,700;1,400&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
/* Layout: una colonna di lettura larga, strati come una sezione di scavo; i dati in tabelle ordinabili e barre disegnate a scala. */
:root {
  --terra: #efece4; --strato: #e3ddd0; --carta: #faf8f3; --inchiostro: #23201b; --tenue: #6b6456;
  --ocra: #a4661c; --ocra-tenue: #a4661c22; --riga: #d5cdbd;
  --bene: #3f7a4a; --male: #a33a2a; --neutro: #7d7462;
  --s1: #a4661c; --s2: #2f5d7c; --s3: #6f4a8c; --s4: #3f7a4a; --s5: #a33a2a; --s6: #7d7462; --s7: #2b7f7a; --s8: #8a7a1e; --s9: #b04f78; --s10: #4a4f9a;
  --titolo: "Alegreya SC", Georgia, serif; --testo: "Alegreya Sans", "Segoe UI", system-ui, sans-serif;
  --dato: "IBM Plex Mono", ui-monospace, Menlo, monospace;
}
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) {
  --terra: #1c1a16; --strato: #26231d; --carta: #211e19; --inchiostro: #ece6da; --tenue: #a79f8e;
  --ocra: #d99a4a; --ocra-tenue: #d99a4a26; --riga: #3a352c; --bene: #7cbf86; --male: #e07a66; --neutro: #a79f8e;
  --s1: #d99a4a; --s2: #6fa6cc; --s3: #b08ad0; --s4: #7cbf86; --s5: #e07a66; --s6: #a79f8e; --s7: #5cc0b8; --s8: #cbb84e; --s9: #e08ab0; --s10: #9aa0e8; color-scheme: dark } }
:root[data-theme="dark"] {
  --terra: #1c1a16; --strato: #26231d; --carta: #211e19; --inchiostro: #ece6da; --tenue: #a79f8e;
  --ocra: #d99a4a; --ocra-tenue: #d99a4a26; --riga: #3a352c; --bene: #7cbf86; --male: #e07a66; --neutro: #a79f8e;
  --s1: #d99a4a; --s2: #6fa6cc; --s3: #b08ad0; --s4: #7cbf86; --s5: #e07a66; --s6: #a79f8e; --s7: #5cc0b8; --s8: #cbb84e; --s9: #e08ab0; --s10: #9aa0e8; color-scheme: dark }
* { box-sizing: border-box }
body { background: var(--terra); color: var(--inchiostro); font: 17px/1.55 var(--testo); margin: 0 }
.pagina { max-width: 1080px; margin: 0 auto; padding-inline: 20px; padding-block: 28px 64px }
h1, h2, h3 { font-family: var(--titolo); font-weight: 700; text-wrap: balance; line-height: 1.15; margin: 0 }
h1 { font-size: clamp(2rem, 5vw, 3.1rem) }
h2 { font-size: 1.7rem; margin-bottom: .4rem }
h3 { font-size: 1.15rem; margin-block: 1.2rem .4rem }
p { max-width: 68ch; margin: .4rem 0 }
.occhiello { font: 500 .78rem/1 var(--dato); letter-spacing: .12em; text-transform: uppercase; color: var(--ocra) }
.tesi { font-size: 1.2rem; max-width: 62ch; margin-top: .8rem }
header { display: grid; gap: .6rem; padding-bottom: 1.2rem; border-bottom: 3px double var(--riga) }
.scheda { background: var(--carta); border: 1px solid var(--riga); border-radius: 6px; padding: 18px 20px; margin-top: 18px }
.tavoli { position: sticky; top: env(safe-area-inset-top, 0px); z-index: 5; background: var(--terra); display: flex; flex-wrap: wrap; gap: 8px; align-items: center; padding-block: 12px; border-bottom: 1px solid var(--riga) }
.tavoli button { font: 500 .95rem var(--testo); border: 1px solid var(--riga); background: var(--carta); color: var(--inchiostro); padding: 6px 14px; border-radius: 99px; cursor: pointer }
.tavoli button[aria-pressed="true"] { background: var(--inchiostro); color: var(--terra); border-color: var(--inchiostro) }
.tavoli button:focus-visible, th button:focus-visible { outline: 2px solid var(--ocra); outline-offset: 2px }
.tavoli nav { display: flex; flex-wrap: wrap; gap: 4px 14px; margin-left: auto; font-size: .9rem }
.tavoli nav a { color: var(--tenue) } .tavoli nav a:hover { color: var(--ocra) }
section { padding-top: 28px }
.cifre { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; margin-top: 10px }
.cifra { background: var(--carta); border: 1px solid var(--riga); border-radius: 6px; padding: 12px 14px }
.cifra b { display: block; font: 500 1.6rem/1.1 var(--dato); font-variant-numeric: tabular-nums }
.cifra span { font-size: .85rem; color: var(--tenue) }
.tab { overflow-x: auto; margin-top: 8px; border: 1px solid var(--riga); border-radius: 6px; background: var(--carta) }
table { border-collapse: collapse; width: 100%; font-size: .9rem }
th, td { padding: 6px 10px; text-align: left; border-bottom: 1px solid var(--riga); white-space: nowrap }
td.n, th.n { text-align: right; font-family: var(--dato); font-variant-numeric: tabular-nums; font-size: .85rem }
th { background: var(--strato); font-weight: 500; position: sticky; top: 0 }
th button { all: unset; cursor: pointer } th button::after { content: " ↕"; color: var(--tenue); font-size: .75em }
tr:last-child td { border-bottom: 0 }
.barre { display: grid; gap: 6px; margin-top: 8px }
.barra { display: grid; grid-template-columns: minmax(90px, 160px) 1fr 62px; gap: 10px; align-items: center; font-size: .9rem }
.barra .pista { position: relative; height: 16px; background: var(--strato); border-radius: 3px; overflow: hidden }
.barra .pieno { position: absolute; inset: 0 auto 0 0; border-radius: 3px }
.barra .soglia { position: absolute; top: -2px; bottom: -2px; width: 2px; background: var(--inchiostro) }
.barra .fascia { position: absolute; top: 0; bottom: 0; background: var(--ocra-tenue) }
.barra b { font: 500 .85rem var(--dato); text-align: right; font-variant-numeric: tabular-nums }
.pila { display: flex; height: 26px; border-radius: 4px; overflow: hidden; margin-top: 8px }
.pila div { min-width: 2px }
.legenda { display: flex; flex-wrap: wrap; gap: 6px 16px; font-size: .85rem; color: var(--tenue); margin-top: 6px }
.legenda i { display: inline-block; width: 10px; height: 10px; border-radius: 2px; margin-right: 5px; vertical-align: -1px }
.chip { display: inline-block; padding: 1px 8px; border-radius: 99px; font: 500 .75rem var(--dato) }
.chip.bene { background: color-mix(in srgb, var(--bene) 18%, transparent); color: var(--bene) }
.chip.male { background: color-mix(in srgb, var(--male) 18%, transparent); color: var(--male) }
.chip.neutro { background: var(--strato); color: var(--tenue) }
.due { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 18px }
.due > * { min-width: 0 }
.nota { font-size: .88rem; color: var(--tenue) }
ul.punti { padding-left: 1.1rem; max-width: 72ch } ul.punti li { margin: .3rem 0 }
@media (prefers-reduced-motion: no-preference) { .pieno { transition: width .4s ease } }
</style>
<div class="pagina">
<header>
  <span class="occhiello">La Strada delle Ere · versione 2 · partite simulate</span>
  <h1>Come si giocano le partite</h1>
  <p class="tesi" id="tesi"></p>
</header>
<div class="scheda" id="lampo"></div>
<div class="tavoli" role="group" aria-label="Numero di giocatori">
  <button type="button" id="t2" data-n="2">2 giocatori</button>
  <button type="button" id="t3" data-n="3">3 giocatori</button>
  <button type="button" id="t4" data-n="4">4 giocatori</button>
  <nav aria-label="Sezioni"><a href="#esito">Esito</a><a href="#strategie">Strategie</a><a href="#punti">Punti</a><a href="#risorse">Risorse</a><a href="#edifici">Edifici</a><a href="#potenziamenti">Potenziamenti</a><a href="#personaggi">Personaggi</a><a href="#ere">Ere ed eventi</a><a href="#altro">Tessere, eredità, monumenti</a></nav>
</div>
<main id="corpo"></main>
<section id="metodo"><h2>Come sono state giocate</h2><div id="metodo-testo"></div></section>
</div>
<script id="dati" type="application/json">__DATI__</script>
<script id="note" type="application/json">__NOTE__</script>
<script>
const DATI = JSON.parse(document.getElementById('dati').textContent);
const NOTE = JSON.parse(document.getElementById('note').textContent);
const NOMI_STRAT = {rendita:'Rendita', lampo:'Lampo', scavo:'Scavo', continuita:'Continuità', bilanciata:'Bilanciata', obiettivi:'Obiettivi', verticale:'Verticale'};
const NOMI_CANALI = {lampo:'Lampo', rendita:'Rendita', scavo:'Scavo', continuita:'Continuità', scheletri:'Scheletri', cultura:'PV dai potenziamenti e personaggi', effetti_finali:'Effetti finali', eredita:'Eredità', monumenti:'Monumenti', verticalita:'Verticalità'};
const NOMI_FONTI = {terreno:'Terreno (produzione base)', tessera:'Tessere dell\'era', edifici:'Produzione degli edifici', passa:'Passare', personaggi:'Personaggi', effetti:'Potenziamenti ed effetti', centro:'Centro urbano', altro:'Altro'};
const NOMI_USI = {costruire:'Costruire', potenziare:'Potenziare', ristrutturare:'Ristrutturare', reclutare:'Reclutare', dinastia:'Dinastia', tessera:'Cambi delle tessere', dispersione:'Buttate a fine era (tetto)', altro:'Altro'};
const RIS = [['pietra','Costruzione','var(--s1)'],['oro','Denaro','var(--s2)'],['idee','Idee','var(--s3)']];
const COLORI = ['var(--s1)','var(--s2)','var(--s3)','var(--s4)','var(--s5)','var(--s7)','var(--s8)','var(--s9)','var(--s10)','var(--s6)'];
const f1 = x => x == null ? '—' : x.toFixed(1).replace('.', ',');
const f2 = x => x == null ? '—' : x.toFixed(2).replace('.', ',');
const pc = x => x == null ? '—' : Math.round(x * 100) + ' %';
const esc = s => String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const ERRORE = {2: .06, 3: .05, 4: .04};

function barre(righe, max, opz = {}) {
  return '<div class="barre">' + righe.map(r => {
    const w = Math.max(0, Math.min(100, r.v / max * 100));
    const fascia = opz.fascia ? `<div class="fascia" style="left:${(opz.fascia[0]/max*100).toFixed(1)}%;width:${((opz.fascia[1]-opz.fascia[0])/max*100).toFixed(1)}%"></div>` : '';
    const soglia = opz.soglia != null ? `<div class="soglia" style="left:${(opz.soglia/max*100).toFixed(1)}%"></div>` : '';
    return `<div class="barra"><span>${esc(r.nome)}</span><div class="pista">${fascia}<div class="pieno" style="width:${w.toFixed(1)}%;background:${r.colore || 'var(--ocra)'}"></div>${soglia}</div><b>${r.testo}</b></div>`;
  }).join('') + '</div>';
}
function pila(parti) {
  const tot = parti.reduce((a, p) => a + p.v, 0) || 1;
  return `<div class="pila" role="img" aria-label="${esc(parti.map(p => p.nome + ' ' + f1(p.v)).join(', '))}">` +
    parti.map(p => `<div style="width:${(p.v/tot*100).toFixed(2)}%;background:${p.colore}" title="${esc(p.nome)}: ${f1(p.v)}"></div>`).join('') +
    '</div><div class="legenda">' + parti.map(p => `<span><i style="background:${p.colore}"></i>${esc(p.nome)} ${f1(p.v)}</span>`).join('') + '</div>';
}
let conta = 0;
function tabella(colonne, righe) {
  const id = 'tb' + (conta++);
  const testa = colonne.map((c, i) => `<th class="${c.n ? 'n' : ''}"><button type="button" data-t="${id}" data-c="${i}">${esc(c.t)}</button></th>`).join('');
  const corpo = righe.map(r => '<tr>' + colonne.map(c => `<td class="${c.n ? 'n' : ''}" data-v="${esc(c.ord ? c.ord(r) : (c.v(r) ?? ''))}">${c.f ? c.f(r) : esc(c.v(r) ?? '—')}</td>`).join('') + '</tr>').join('');
  return `<div class="tab"><table id="${id}"><thead><tr>${testa}</tr></thead><tbody>${corpo}</tbody></table></div>`;
}
document.addEventListener('click', e => {
  const b = e.target.closest('th button'); if (!b) return;
  const t = document.getElementById(b.dataset.t), c = +b.dataset.c;
  const righe = [...t.tBodies[0].rows];
  const dir = t.dataset.c == c && t.dataset.d == '1' ? -1 : 1;
  t.dataset.c = c; t.dataset.d = dir == 1 ? '1' : '-1';
  righe.sort((a, z) => {
    const x = a.cells[c].dataset.v, y = z.cells[c].dataset.v, nx = parseFloat(x), ny = parseFloat(y);
    const v = (!isNaN(nx) && !isNaN(ny)) ? nx - ny : x.localeCompare(y, 'it');
    return -dir * v;
  });
  righe.forEach(r => t.tBodies[0].appendChild(r));
});
function chipVince(v, n) {
  const d = v - 1 / n, e = ERRORE[n];
  if (d > e) return `<span class="chip male">sopra di ${Math.round(d*100)}</span>`;
  if (d < -e) return `<span class="chip male">sotto di ${Math.round(-d*100)}</span>`;
  return '<span class="chip bene">nell\'errore</span>';
}

function disegna(n) {
  const D = DATI.find(d => d.giocatori == n); if (!D) return;
  const P = D.panoramica, h = [];
  const nota = (NOTE.tavoli || {})[n] || [];
  h.push(`<section id="esito"><span class="occhiello">${n} giocatori · ${D.partite} partite</span><h2>Esito e ritmo</h2>`);
  if (nota.length) h.push('<ul class="punti">' + nota.map(x => `<li>${esc(x)}</li>`).join('') + '</ul>');
  h.push(`<div class="cifre">
    <div class="cifra"><b>${f1(P.pv_medi)}</b><span>PV medi a testa</span></div>
    <div class="cifra"><b>${f1(P.pv_vincitore)}</b><span>PV del vincitore</span></div>
    <div class="cifra"><b>${f1(P.distacco_medio)}</b><span>distacco fra primo e secondo</span></div>
    <div class="cifra"><b>${pc(P.partite_strette)}</b><span>partite vinte di 3 PV o meno</span></div>
    <div class="cifra"><b>${f1(P.edifici_a_testa)}</b><span>edifici costruiti a testa</span></div>
    <div class="cifra"><b>${f1(P.livello_max)}</b><span>livello più alto della strada</span></div>
    <div class="cifra"><b>${f1(P.in_piedi_fine)}</b><span>edifici in piedi a fine partita (su ${f1(P.costruiti_partita)})</span></div>
  </div></section>`);
  // strategie
  const S = D.strategie;
  h.push(`<section id="strategie"><h2>Strategie</h2><p>Ogni bot segue una strategia. Il riquadro chiaro è l'errore di misura attorno alla quota attesa (${pc(1/n)}, la linea): dentro, la strategia è in equilibrio.</p>`);
  const maxv = Math.max(.7, ...S.map(s => s.vince));
  h.push(barre(S.map((s, i) => ({nome: NOMI_STRAT[s.nome] || s.nome, v: s.vince, testo: pc(s.vince), colore: COLORI[i % 6]})), maxv, {soglia: 1/n, fascia: [1/n - ERRORE[n], 1/n + ERRORE[n]]}));
  const canaliS = [...new Set(S.flatMap(s => Object.keys(s.canali)))].filter(c => S.some(s => (s.canali[c] || 0) >= .5));
  h.push(tabella([
    {t: 'strategia', v: r => NOMI_STRAT[r.nome] || r.nome},
    {t: 'vince', n: 1, v: r => r.vince, f: r => pc(r.vince)},
    {t: 'equilibrio', v: r => r.vince, f: r => chipVince(r.vince, n)},
    {t: 'PV medi', n: 1, v: r => r.pv, f: r => f1(r.pv)},
    {t: 'posto medio', n: 1, v: r => r.posto, f: r => f2(r.posto)},
    ...canaliS.map(c => ({t: NOMI_CANALI[c] || c, n: 1, v: r => r.canali[c] || 0, f: r => f1(r.canali[c] || 0)}))
  ], S));
  h.push('</section>');
  // punti
  const C = Object.entries(D.canali).filter(([c, v]) => v.tutti >= .05).sort((a, z) => z[1].tutti - a[1].tutti);
  h.push(`<section id="punti"><h2>Da dove arrivano i punti</h2><h3>Tutti i giocatori (PV medi a testa)</h3>`);
  h.push(pila(C.map(([c, v], i) => ({nome: NOMI_CANALI[c] || c, v: v.tutti, colore: COLORI[i % COLORI.length]}))));
  h.push('<h3>Solo i vincitori</h3>');
  h.push(pila(C.map(([c, v], i) => ({nome: NOMI_CANALI[c] || c, v: v.vincitori, colore: COLORI[i % COLORI.length]}))));
  h.push('</section>');
  // risorse
  const E = D.entrate, U = D.uscite;
  const totE = r => Object.values(E).reduce((a, x) => a + (x[r] || 0), 0);
  const totU = r => Object.values(U).reduce((a, x) => a + (x[r] || 0), 0);
  h.push(`<section id="risorse"><h2>Risorse</h2><p>Valori medi a testa per partita.</p><div class="due"><div><h3>Da dove arrivano</h3>`);
  h.push(tabella([{t: 'fonte', v: r => NOMI_FONTI[r[0]] || r[0]}, ...RIS.map(([k, nome]) => ({t: nome, n: 1, v: r => r[1][k] || 0, f: r => f1(r[1][k] || 0)})),
    {t: 'totale', n: 1, v: r => RIS.reduce((a, [k]) => a + (r[1][k] || 0), 0), f: r => f1(RIS.reduce((a, [k]) => a + (r[1][k] || 0), 0))}],
    Object.entries(E).sort((a, z) => RIS.reduce((s, [k]) => s + (z[1][k] || 0), 0) - RIS.reduce((s, [k]) => s + (a[1][k] || 0), 0))));
  h.push('</div><div><h3>Dove vanno</h3>');
  h.push(tabella([{t: 'uso', v: r => NOMI_USI[r[0]] || r[0]}, ...RIS.map(([k, nome]) => ({t: nome, n: 1, v: r => r[1][k] || 0, f: r => f1(r[1][k] || 0)})),
    {t: 'totale', n: 1, v: r => RIS.reduce((a, [k]) => a + (r[1][k] || 0), 0), f: r => f1(RIS.reduce((a, [k]) => a + (r[1][k] || 0), 0))}],
    Object.entries(U).sort((a, z) => RIS.reduce((s, [k]) => s + (z[1][k] || 0), 0) - RIS.reduce((s, [k]) => s + (a[1][k] || 0), 0))));
  h.push('</div></div><h3>Bilancio delle tre risorse</h3>');
  const maxR = Math.max(...RIS.map(([k]) => totE(k)));
  h.push(barre(RIS.flatMap(([k, nome, col]) => [
    {nome: nome + ' entrata', v: totE(k), testo: f1(totE(k)), colore: col},
    {nome: nome + ' buttata', v: (U.dispersione || {})[k] || 0, testo: f1((U.dispersione || {})[k] || 0), colore: 'var(--male)'}]), maxR));
  h.push('<h3>Azioni a testa</h3>');
  const A = Object.entries(D.azioni).sort((a, z) => z[1] - a[1]);
  h.push(barre(A.map(([k, v]) => ({nome: k, v, testo: f1(v), colore: 'var(--s2)'})), Math.max(...A.map(a => a[1]))));
  h.push('</section>');
  // edifici
  const B = D.edifici.filter(b => b.costruiti > 0);
  const top = (arr, key, k = 8, rev = true) => [...arr].sort((a, z) => rev ? z[key] - a[key] : a[key] - z[key]).slice(0, k);
  const soglia = arr => arr.filter(b => b.costruiti >= .15);
  h.push(`<section id="edifici"><h2>Edifici</h2><div class="due"><div><h3>I più costruiti (a partita)</h3>`);
  h.push(barre(top(B, 'costruiti').map(b => ({nome: b.nome, v: b.costruiti, testo: f2(b.costruiti), colore: 'var(--s1)'})), top(B, 'costruiti')[0].costruiti));
  h.push('<h3>I meno costruiti</h3>');
  const meno = [...D.edifici].sort((a, z) => a.costruiti - z.costruiti).slice(0, 8);
  h.push(barre(meno.map(b => ({nome: b.nome, v: b.costruiti, testo: f2(b.costruiti), colore: 'var(--neutro)'})), top(B, 'costruiti')[0].costruiti));
  h.push('</div><div><h3>Crollano prima (quota crollata per un evento)</h3>');
  h.push(barre(top(soglia(B), 'crollato').map(b => ({nome: b.nome, v: b.crollato, testo: pc(b.crollato), colore: 'var(--male)'})), 1));
  h.push('<h3>Resistono (intatti a fine partita)</h3>');
  h.push(barre(top(soglia(B), 'intatto_fine').map(b => ({nome: b.nome, v: b.intatto_fine, testo: pc(b.intatto_fine), colore: 'var(--bene)'})), 1));
  h.push('</div></div><h3>Rendono di più (PV al proprietario per edificio costruito)</h3>');
  h.push(barre(top(soglia(B), 'pv', 10).map(b => ({nome: b.nome, v: b.pv, testo: f1(b.pv), colore: 'var(--ocra)'})), top(soglia(B), 'pv')[0].pv));
  h.push('<h3>Tutti gli edifici</h3><p class="nota">"Del vincitore" è la quota di copie costruite da chi poi vince: sopra ' + pc(1/n) + ' la carta accompagna le vittorie. Clic sulle intestazioni per ordinare.</p>');
  h.push(tabella([
    {t: 'era', n: 1, v: r => r.era}, {t: 'edificio', v: r => r.nome},
    {t: 'a partita', n: 1, v: r => r.costruiti, f: r => f2(r.costruiti)},
    {t: 'del vincitore', n: 1, v: r => r.del_vincitore ?? -1, f: r => pc(r.del_vincitore)},
    {t: 'PV resi', n: 1, v: r => r.pv ?? -1, f: r => f1(r.pv)},
    {t: 'crollato', n: 1, v: r => r.crollato ?? -1, f: r => pc(r.crollato)},
    {t: 'crolla nell\'era', n: 1, v: r => r.crollo_subito ?? -1, f: r => pc(r.crollo_subito)},
    {t: 'ere prima del crollo', n: 1, v: r => r.ere_prima_crollo ?? -1, f: r => f1(r.ere_prima_crollo)},
    {t: 'intatto a fine', n: 1, v: r => r.intatto_fine ?? -1, f: r => pc(r.intatto_fine)},
    {t: 'sepolto', n: 1, v: r => r.sepolto ?? -1, f: r => pc(r.sepolto)},
    {t: 'spianato', n: 1, v: r => r.spianato ?? -1, f: r => pc(r.spianato)},
    {t: 'costruito sopra', n: 1, v: r => r.sopra ?? -1, f: r => pc(r.sopra)},
    {t: 'resistenza', n: 1, v: r => r.resistenza}, {t: 'Lampo', n: 1, v: r => r.lampo}, {t: 'Rendita', n: 1, v: r => r.rendita}, {t: 'Scavo', n: 1, v: r => r.scavo},
  ], D.edifici));
  h.push('</section>');
  // potenziamenti
  const Pz = D.potenziamenti;
  h.push(`<section id="potenziamenti"><h2>Potenziamenti</h2><div class="due"><div><h3>I più presi (a partita)</h3>`);
  h.push(barre(top(Pz, 'presi', 10).map(u => ({nome: u.nome, v: u.presi, testo: f2(u.presi), colore: 'var(--s3)'})), top(Pz, 'presi')[0].presi || 1));
  h.push('</div><div><h3>I meno presi</h3>');
  h.push(barre([...Pz].sort((a, z) => a.presi - z.presi).slice(0, 10).map(u => ({nome: u.nome, v: u.presi, testo: f2(u.presi), colore: 'var(--neutro)'})), top(Pz, 'presi')[0].presi || 1));
  h.push('</div></div>');
  h.push(tabella([{t: 'era', n: 1, v: r => r.era}, {t: 'potenziamento', v: r => r.nome}, {t: 'famiglia', v: r => r.famiglia},
    {t: 'a partita', n: 1, v: r => r.presi, f: r => f2(r.presi)}, {t: 'del vincitore', n: 1, v: r => r.del_vincitore ?? -1, f: r => pc(r.del_vincitore)}], Pz));
  h.push('</section>');
  // personaggi
  const Pe = D.personaggi;
  h.push(`<section id="personaggi"><h2>Personaggi</h2><p>"Vince" è la quota di partite vinte da chi ha avuto quel personaggio: sopra ${pc(1/n)} il personaggio accompagna le vittorie.</p>`);
  h.push(barre([...Pe].sort((a, z) => z.vince - a.vince).map(p => ({nome: p.nome, v: p.vince, testo: pc(p.vince), colore: p.vince - 1/n > ERRORE[n] ? 'var(--male)' : (1/n - p.vince > ERRORE[n] ? 'var(--neutro)' : 'var(--s4)')})), Math.max(...Pe.map(p => p.vince), .6), {soglia: 1/n}));
  h.push(tabella([{t: 'personaggio', v: r => r.nome}, {t: 'preso a partita', n: 1, v: r => r.presi, f: r => f2(r.presi)},
    {t: 'vince', n: 1, v: r => r.vince, f: r => pc(r.vince)}, {t: 'PV medi di chi lo ha', n: 1, v: r => r.pv, f: r => f1(r.pv)}], Pe));
  h.push('</section>');
  // ere ed eventi
  h.push(`<section id="ere"><h2>Ere ed eventi</h2><div class="due"><div><h3>Costruiti e crollati per era (a partita)</h3>`);
  const maxE = Math.max(...D.ere.map(e => e.costruiti));
  h.push(barre(D.ere.flatMap(e => [{nome: 'Era ' + e.era + ' costruiti', v: e.costruiti, testo: f1(e.costruiti), colore: 'var(--s2)'}, {nome: 'Era ' + e.era + ' crollati', v: e.crolli, testo: f1(e.crolli), colore: 'var(--male)'}]), maxE));
  h.push('</div><div><h3>Eventi: edifici crollati quando escono</h3>');
  h.push(tabella([{t: 'era', n: 1, v: r => r.era}, {t: 'evento', v: r => r.nome}, {t: 'esce', n: 1, v: r => r.uscito, f: r => pc(r.uscito)}, {t: 'crolli', n: 1, v: r => r.crolli, f: r => f1(r.crolli)}], D.eventi));
  h.push('</div></div></section>');
  // tessere, eredita, monumenti
  h.push(`<section id="altro"><h2>Tessere, eredità, monumenti</h2><div class="due"><div><h3>Tessere dell'era: volte che scattano a partita</h3>`);
  h.push(tabella([{t: 'tessera', v: r => r.nome}, {t: 'scatta', n: 1, v: r => r.scatta, f: r => f2(r.scatta)}], D.tessere));
  h.push('</div><div><h3>Eredità segrete</h3>');
  h.push(tabella([{t: 'eredità', v: r => r.nome}, {t: 'riuscita', n: 1, v: r => r.riuscita, f: r => pc(r.riuscita)}, {t: 'vince', n: 1, v: r => r.vince, f: r => pc(r.vince)}], D.eredita));
  h.push('<h3>Monumenti presi a partita</h3>');
  h.push(tabella([{t: 'monumento', v: r => r.nome}, {t: 'a partita', n: 1, v: r => r.presi, f: r => f2(r.presi)}], D.monumenti));
  h.push('</div></div></section>');
  document.getElementById('corpo').innerHTML = h.join('');
  document.querySelectorAll('.tavoli button').forEach(b => b.setAttribute('aria-pressed', b.dataset.n == n ? 'true' : 'false'));
  try { localStorage.setItem('tavolo', n) } catch (e) {}
}
document.getElementById('tesi').textContent = NOTE.tesi || '';
document.getElementById('lampo').innerHTML = NOTE.lampo_html || '';
document.getElementById('metodo-testo').innerHTML = NOTE.metodo_html || '';
document.querySelectorAll('.tavoli button').forEach(b => b.addEventListener('click', () => disegna(+b.dataset.n)));
let iniziale = 3; try { iniziale = +(localStorage.getItem('tavolo') || 3) } catch (e) {}
disegna(DATI.some(d => d.giocatori == iniziale) ? iniziale : DATI[0].giocatori);
</script>
"""
def js(x):
    return json.dumps(x, ensure_ascii=False).replace("</", "<\\/")

print(PAGINA.replace("__DATI__", js(dati)).replace("__NOTE__", js(note)))
