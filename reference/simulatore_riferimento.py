SKEL=False
SPOL=''
RIES_CAL=False
RIESUMA=False
RIES_INV=False
RIES_MAX=3
W_P=0.8
W_O=1.2
COSTI_A=False
FIUMEPROP=False
MERCATO=False
UNIQ=False
TERR2=False
COLLIVELLO=False
COLLPUNTI=False
PROSP=False
LISTINO=False
S2=False
CAPDIFF=False
SPEC=2
FLEX='none'
RESCAP=5
EMERG=False
VMODE='A'
ERACAP=False
CONT=True
VBONUS={1:1,2:3,3:6,4:9}
SCAVOX=1.0
# -*- coding: utf-8 -*-
"""La Strada delle Ere — motore v0.16: griglia 5 binari x 10 colonne."""
import json, random, re, statistics as S
INC=json.load(open('listino117.json',encoding='utf-8'))
COSTA=json.load(open('costiA.json',encoding='utf-8'))
from collections import defaultdict, Counter

CARDS=json.load(open('cards.json',encoding='utf-8'))
RB={'Castello':3,'Abbazia':3,'Ponte monumentale':3,'Fortezza bastionata':3,'Duomo':4}
for c in CARDS:
    if c.get('t')=='E' and c['nome'] in RB: c['r']=RB[c['nome']]
import os
LX=float(os.environ.get('LAMPOX','1.0'))
for c in CARDS:
    if c.get('t')=='E' and 'l' in c: c['l']=max(1,round(c['l']*LX))
E=[c for c in CARDS if c['t']=='E']

def cost(c):
    P=re.search(r'(\d)P',c.get('costo','')); O=re.search(r'(\d)O',c.get('costo',''))
    p=int(P.group(1)) if P else 0; o=int(O.group(1)) if O else 0
    if COSTI_A and c.get('nome') in COSTA: p,o=COSTA[c['nome']]
    if LISTINO: o+=INC.get(c.get('nome',''),0)
    return (p,o)
def span(c):
    l=c['lar']
    if l.startswith('XL'): return 3
    return {'⅓':1,'½':1,'L':2}[l]   # unità = slot; L=2, XL=3
def prod(c):
    out={'pietra':0,'oro':0,'cultura':0}
    for n,r in re.findall(r'(\d)\s*(pietra|oro|cultura)', c.get('fx','')):
        out[r]+=int(n)
    return out
def classes(c):
    s=set()
    if c.get('cl'): s.add(c['cl'])
    if c.get('cl2'): s.add(c['cl2'])
    return s
def lvl_req(c):
    m=re.search(r'livello (\d)\+', c.get('fx','')); return int(m.group(1)) if m else 0
def ter_req(c):
    t=c.get('ter','—'); return None if t in ('—','') else t

TERR_POOL=['pianura']*3+['fiume']*3+['collina']*2+['bosco']*2
FORCE={1:2,2:3,3:4,4:5}
EVENTS={1:[('terr',('fiume',-1)),('class',{'REL':1,'COM':-1}),('unprot',-1)],
        2:[('largo',-1),('class',{'ING':1,'MIL':-1}),('unprot',-1)],
        3:[('terr',('fiume',-1)),('class',{'MIL':1,'CIV':-1}),('crowd',-1)],
        4:[('terr',('fiume',-1)),('class',{'REL':1,'CUL':-1}),('scavo',-1)]}

class B:
    __slots__=('card','owner','era','c0','c1','lvl','state','bonus','vet','prot','buried_on','sk')
    def __init__(s,card,owner,era,c0,c1,lvl):
        s.card=card; s.owner=owner; s.era=era; s.c0=c0; s.c1=c1; s.lvl=lvl
        s.state='intact'; s.bonus=0; s.vet=0; s.prot=0; s.buried_on=[]; s.sk=None

class P:
    def __init__(s,i,strat):
        s.i=i; s.strat=strat; s.pietra=2; s.oro=0
        s.score=defaultdict(float); s.workers=3; s.builds=0; s.din=False; s.recl=[]
    @property
    def total(s): return sum(s.score.values())

def flex_ok(card):
    if FLEX=='none': return False
    cls=set()
    if card.get('cl'): cls.add(card['cl'])
    if card.get('cl2'): cls.add(card['cl2'])
    pure = cls<= {'COM'} or cls<={'ING'}
    if FLEX=='F1': return pure and card.get('scavo',0)%2==0
    if FLEX=='F2': return pure
    if FLEX=='H': return card['era']>=4
    if FLEX=='ALL': return True
    return False

def run(nplayers,strats,seed,NC=10,TERRAP=1):
    rnd=random.Random(seed)
    if UNIQ:
        deck=[('pianura','cantieri'),('pianura','mercato'),('pianura','cereali'),('pianura','strade'),
              ('collina','castello'),('collina','cave'),('collina','panoramica'),
              ('bosco','sacro'),('bosco','caccia'),('bosco','altofusto'),
              ('fiume','porto'),('fiume','guado')]
        rnd.shuffle(deck); sel=deck[:NC]
        terr=[t for t,_ in sel]; EFF=[e for _,e in sel]
    else:
        pool=(TERR_POOL*3)[:]; rnd.shuffle(pool); terr=pool[:NC]; EFF=['']*NC
    ERA_NOW=[1]
    rail={e:[None]*NC for e in range(1,6)}      # binario d'era -> occupante per colonna
    stack={c:[] for c in range(NC)}             # colonna -> lista di edifici sopraelevati (livello 1+)
    all_b=[]
    _PRES=EFF[:] if UNIQ else []
    players=[P(i,strats[i]) for i in range(nplayers)]
    decks={e:[c for c in E if c['era']==e] for e in range(1,6)}
    for d in decks.values(): rnd.shuffle(d)
    st={'built':0,'sopra':0,'terrap':0,'blocked':0,'turns':0,'ruderi':0,'rovine':0,
        'maxlvl':0,'buried':0,'noplace':0,'h1':0,'h2':0,'h3':0,'h4':0,'hmax':0,'lev0':0,'lev1':0,'lev2':0,'lev3':0,'lev4':0,'lev5':0,'freerider':0,'lv4game':0,'nb_costo':0,'nb_cap':0,'nb_terreno':0,'nb_spazio':0,'nb_mercato':0,'nb_poverta':0,'nb_mismatch':0,'nb_oro':0,'nb_pietra':0,'flexuse':0,'flex_p2o':0,'flex_o2p':0,'rteo':0.0,'rbase':0.0,'rvet':0.0,'rperso_ev':0.0,'rperso_sot':0.0,'rperso_spi':0.0,'flexbuy':0,'flexavail':0,'spian':0,'spian_rend':0,'centri_att':0,'ries_n':0,'sk_ass':0,'sk_trov':0,'sk_pv':0,'recl_tot':0,'ries_pv':0,'merc_uso':0,'merc_necessario':0,'merc_opportunistico':0,'merc_era1':0,'merc_era2':0,'merc_era3':0,'merc_era4':0,'merc_era5':0,'merc_pianura':0,'merc_collina':0,'merc_bosco':0,'ATT_pianura':0,'BASE_P_pianura':0,'BASE_O_pianura':0,'OWN_pianura':0,'REND_P_pianura':0,'REND_O_pianura':0,'PROSP_pianura':0,'BUILD_pianura':0,'NCOL_pianura':0,'ATT_collina':0,'BASE_P_collina':0,'BASE_O_collina':0,'OWN_collina':0,'REND_P_collina':0,'REND_O_collina':0,'PROSP_collina':0,'BUILD_collina':0,'NCOL_collina':0,'ATT_bosco':0,'BASE_P_bosco':0,'BASE_O_bosco':0,'OWN_bosco':0,'REND_P_bosco':0,'REND_O_bosco':0,'PROSP_bosco':0,'BUILD_bosco':0,'NCOL_bosco':0,'ATT_fiume':0,'BASE_P_fiume':0,'BASE_O_fiume':0,'OWN_fiume':0,'REND_P_fiume':0,'REND_O_fiume':0,'PROSP_fiume':0,'BUILD_fiume':0,'NCOL_fiume':0,'ATTera1_pianura':0,'ATTera1_collina':0,'ATTera1_bosco':0,'ATTera1_fiume':0,'ATTera2_pianura':0,'ATTera2_collina':0,'ATTera2_bosco':0,'ATTera2_fiume':0,'ATTera3_pianura':0,'ATTera3_collina':0,'ATTera3_bosco':0,'ATTera3_fiume':0,'ATTera4_pianura':0,'ATTera4_collina':0,'ATTera4_bosco':0,'ATTera4_fiume':0,'ATTera5_pianura':0,'ATTera5_collina':0,'ATTera5_bosco':0,'ATTera5_fiume':0,'pres_cantieri':0,'att_cantieri':0,'build_cantieri':0,'uso_cantieri':0,'val_cantieri':0,'pres_mercato':0,'att_mercato':0,'build_mercato':0,'uso_mercato':0,'val_mercato':0,'pres_cereali':0,'att_cereali':0,'build_cereali':0,'uso_cereali':0,'val_cereali':0,'pres_strade':0,'att_strade':0,'build_strade':0,'uso_strade':0,'val_strade':0,'pres_castello':0,'att_castello':0,'build_castello':0,'uso_castello':0,'val_castello':0,'pres_cave':0,'att_cave':0,'build_cave':0,'uso_cave':0,'val_cave':0,'pres_panoramica':0,'att_panoramica':0,'build_panoramica':0,'uso_panoramica':0,'val_panoramica':0,'pres_sacro':0,'att_sacro':0,'build_sacro':0,'uso_sacro':0,'val_sacro':0,'pres_caccia':0,'att_caccia':0,'build_caccia':0,'uso_caccia':0,'val_caccia':0,'pres_altofusto':0,'att_altofusto':0,'build_altofusto':0,'uso_altofusto':0,'val_altofusto':0,'pres_porto':0,'att_porto':0,'build_porto':0,'uso_porto':0,'val_porto':0,'pres_guado':0,'att_guado':0,'build_guado':0,'uso_guado':0,'val_guado':0,'bonus_bosco':0,'oro_prosp':0,'oro_passivo':0,'rend_teo':0.0,'rend_eff':0.0}

    for _e in _PRES: st['pres_'+_e]+=1
    for _t in terr: st['NCOL_'+_t]+=1

    def occupied(e,c0,c1): return any(rail[e][c] is not None for c in range(c0,c1))
    def top_at(c):
        return stack[c][-1] if stack[c] else None
    def collina_base(c):
        return 1 if (COLLIVELLO and terr[c]=='collina') else 0

    def ground_level(c,pi=None):
        """livello disponibile sopra la colonna c e l'edificio che farà da base.
        Base valida: un Rudere di chiunque, oppure un proprio Intatto (spianamento)."""
        t=top_at(c)
        if t is None:
            best=None
            for e in range(1,6):
                b=rail[e][c]
                if b is None: continue
                if b.state=='rudere': best=b
                elif b.state=='intact' and pi is not None and b.owner==pi and best is None: best=b
            return (1+collina_base(c),best) if best else (collina_base(c),None)
        if t.state=='rudere': return (t.lvl+1,t)
        if t.state=='intact' and pi is not None and t.owner==pi: return (t.lvl+1,t)
        return (None,None)

    def base_prod(c):
        t=terr[c]
        return (1,1) if t=='fiume' else (2,0)

    def activate(pl,c):
        p_,o_=base_prod(c)
        T=terr[c]
        if FIUMEPROP and T=='fiume':
            _m=[rail[e][c] for e in range(1,6) if rail[e][c]]+list(stack[c])
            if not any(b.owner==pl.i and b.state=='intact' for b in _m):
                o_=0; p_+=1
        pl.pietra+=p_; pl.oro+=o_
        st['ATT_'+T]+=1; st['ATTera%d_%s'%(ERA_NOW[0],T)]+=1
        st['BASE_P_'+T]+=p_; st['BASE_O_'+T]+=o_
        _mine=[rail[e][c] for e in range(1,6) if rail[e][c]]+list(stack[c])
        if any(b.owner==pl.i and b.state=='intact' for b in _mine): st['OWN_'+T]+=1
        _rp=0;_ro=0
        for b in _mine:
            if b.state=='intact':
                pr=prod(b.card)
                if b.owner==pl.i: _rp+=pr['pietra']; _ro+=pr['oro']
        st['REND_P_'+T]+=_rp; st['REND_O_'+T]+=_ro
        if MERCATO and T!='fiume' and pl.pietra>=2:
            # converte solo se sblocca una carta del mercato altrimenti inaccessibile
            need=False; opp=False
            for cd in market:
                cp,co=cost(cd)
                if pl.pietra>=cp and pl.oro>=co: opp=True
                elif pl.pietra-2>=cp and pl.oro+1>=co: need=True
            if need:
                pl.pietra-=2; pl.oro+=1
                st['merc_uso']+=1; st['merc_era%d'%ERA_NOW[0]]+=1; st['merc_'+T]+=1
                st['merc_necessario']+=1
            elif opp and pl.pietra>=5 and pl.oro<=1:
                pl.pietra-=2; pl.oro+=1
                st['merc_uso']+=1; st['merc_era%d'%ERA_NOW[0]]+=1; st['merc_'+T]+=1
                st['merc_opportunistico']+=1
        if UNIQ:
            ef=EFF[c]; st['att_'+ef]+=1
            mine=[rail[e][c] for e in range(1,6) if rail[e][c]]+list(stack[c])
            has_mine=any(b.owner==pl.i and b.state=='intact' for b in mine)
            if ef=='mercato' and pl.pietra>=2:
                pl.pietra-=2; pl.oro+=1; st['uso_mercato']+=1; st['val_mercato']+=1
            elif ef in ('cereali','caccia') and not has_mine:
                pl.pietra+=1; st['uso_'+ef]+=1; st['val_'+ef]+=1
        if TERR2 and terr[c]=='bosco':
            if any((rail[e][c] and rail[e][c].state=='intact' and rail[e][c].owner==pl.i and e<ERA_NOW[0]) for e in range(1,6)):
                pl.pietra+=1; st['bonus_bosco']+=1
        if PROSP:
            owners=set(); n=0
            for e in range(1,6):
                b=rail[e][c]
                if b and b.state=='intact': owners.add(b.owner); n+=1
            for b in stack[c]:
                if b.state=='intact': owners.add(b.owner); n+=1
            if n>=3 and len(owners)>=2:
                st['centri_att']+=1; st['PROSP_'+T]+=len(owners)
                for ow in owners:
                    players[ow].oro+=1; st['oro_prosp']+=1
                    if ow!=pl.i: st['oro_passivo']+=1
        for e in range(1,6):
            b=rail[e][c]
            if b and b.state=='intact':
                pr=prod(b.card); ow=players[b.owner]
                ow.pietra+=pr['pietra']; ow.oro+=pr['oro']; ow.score['lampo']+=pr['cultura']
        for b in stack[c]:
            if b.state=='intact':
                pr=prod(b.card); ow=players[b.owner]
                ow.pietra+=pr['pietra']; ow.oro+=pr['oro']; ow.score['lampo']+=pr['cultura']

    def can_build(card,era,c0,pl,mode):
        n=span(card); c1=c0+n
        if c1>NC: return None
        tr=ter_req(card)
        if tr:
            if tr=='pianura adiac. fiume':
                if terr[c0]!='pianura': return None
                if not any(0<=k<NC and terr[k]=='fiume' for k in (c0-1,c1)): return None
            elif tr=='fiume':
                if not any(terr[c]=='fiume' for c in range(c0,c1)): return None
            else:
                near=[terr[k] for k in range(max(0,c0-1),min(NC,c1+1))]
                if UNIQ and any(EFF[k]=='strade' for k in range(c0,c1)):
                    near+= [terr[k] for k in range(max(0,c0-2),min(NC,c1+2))]
                if tr not in near: return None
        if mode=='rail':
            if occupied(era,c0,c1): return None
            base=min(collina_base(x) for x in range(c0,c1))
            if lvl_req(card)>base: return None
            return (c0,c1,base,0)
        # mode == 'sopra'
        lv=None; nvuoti=0; supports=[]
        for c in range(c0,c1):
            l,sup=ground_level(c,pl.i)
            if l is None: return None
            if sup is None: nvuoti+=1
            else: supports.append(sup)
            lv=l if lv is None else max(lv,l)
        if ERACAP and any(c in risen for c in range(c0,c1)): return None
        if not supports: return None
        if lvl_req(card)>lv: return None
        nsp=sum(1 for x in supports if x.state=='intact')
        if SPOL=='RES':
            nspian = -sum(x.card.get('res',0)+x.bonus for x in supports if x.state=='intact')
        elif SPOL=='RES2':
            nspian = -sum((x.card.get('res',0)+x.bonus+1)//2 for x in supports if x.state=='intact')
        else:
            nspian = (-nsp if SPOL=='A' else (0 if SPOL=='B' else nsp))
        return (c0,c1,lv,nvuoti+nspian)

    for era in range(1,6):
        ERA_NOW[0]=era
        market=[decks[era].pop() for _ in range(min(6,len(decks[era])))]
        ev=rnd.choice(EVENTS[era]) if era<5 else None
        used=defaultdict(int); risen=set(); castello_used={}; emerg_used={}
        order=sorted(range(nplayers),key=lambda i:(players[i].builds,rnd.random()))
        for rd in range(4):
            for pi in order:
                pl=players[pi]
                if used[pi]>=pl.workers: continue
                used[pi]+=1; st['turns']+=1
                # piazza: colonna con miglior reddito
                best=(-1,-9)
                for c in range(NC):
                    p_,o_=base_prod(c); v=p_*W_P+o_*W_O
                    for e in range(1,6):
                        b=rail[e][c]
                        if b and b.owner==pi and b.state=='intact':
                            pr=prod(b.card); v+=pr['pietra']*0.8+pr['oro']*1.2+pr['cultura']
                    for b in stack[c]:
                        if b.owner==pi and b.state=='intact':
                            pr=prod(b.card); v+=pr['pietra']*0.8+pr['oro']*1.2+pr['cultura']
                    v+=rnd.random()*0.3
                    if v>best[1]: best=(c,v)
                col=best[0]; activate(pl,col)
                # protezione
                cands=[rail[e][col] for e in range(1,6) if rail[e][col] and rail[e][col].state in ('intact','rudere') and rail[e][col].owner==pi]
                cands+=[b for b in stack[col] if b.owner==pi and b.state in ('intact','rudere')]
                if cands and era<5:
                    t=max(cands,key=lambda b: b.card.get('r',0)*2-(b.card.get('res',0)+b.bonus))
                    t.prot+=2
                # azione: costruisci (rail o sopra)
                opts=[]
                for card in market:
                    Pc,Oc=cost(card)
                    for c0 in range(NC):
                        for mode in ('rail','sopra'):
                            r=can_build(card,era,c0,pl,mode)
                            if not r: continue
                            cc0,cc1,lv,nv=r
                            extra=nv*TERRAP if mode=='sopra' else 0
                            if TERR2 and mode=='sopra' and terr[cc0]=='collina': extra=max(0,extra-nv)
                            tot_p=Pc+extra
                            if UNIQ:
                                ef0=EFF[cc0]
                                if ef0=='cantieri' and span(card)>=2 and tot_p>0: tot_p-=1; st['uso_cantieri']+=1; st['val_cantieri']+=1
                                if ef0=='cave' and mode=='sopra' and tot_p>0: tot_p-=1; st['uso_cave']+=1; st['val_cave']+=1
                                if ef0=='porto' and Oc>=1 and tot_p>0: tot_p-=1; st['uso_porto']+=1; st['val_porto']+=1
                            if terr[cc0]=='pianura' and span(card)>=2: tot_p=max(0,tot_p-1)
                            paid=None
                            if pl.pietra>=tot_p and pl.oro>=Oc:
                                paid=(tot_p,Oc)
                            elif flex_ok(card):
                                # alternativa 1: paga 1O in più al posto di 2P
                                if tot_p>=2 and pl.pietra>=tot_p-2 and pl.oro>=Oc+1: paid=(tot_p-2,Oc+1)
                                # alternativa 2: paga 2P in più al posto di 1O
                                elif Oc>=1 and pl.oro>=Oc-1 and pl.pietra>=tot_p+2: paid=(tot_p+2,Oc-1)
                                if paid:
                                    st['flexuse']+=1
                                    if paid[1]>Oc: st['flex_p2o']+=1
                                    else: st['flex_o2p']+=1
                            if paid is None: continue
                            tot_p,Oc=paid
                            rem=(5-era)
                            res_eff=card.get('res',0)+(1 if terr[cc0]=='collina' else 0)
                            # probabilità stimata di sopravvivere a un evento medio
                            surv=min(0.95,max(0.1,(res_eff+1.0)/(FORCE.get(era,5)+1.0)))
                            v=0.0
                            v+=card.get('l',0)                       # lampo, certo
                            rr=card.get('r',0)
                            if rr:                                    # rendita attesa con vetustà
                                exp=0.0; p_alive=1.0
                                for k in range(rem):
                                    p_alive*=surv
                                    exp+=p_alive*(rr+min(k+1,3))
                                v+=exp
                            pr=prod(card)
                            v+=(pr['pietra']*0.7+pr['oro']*1.1+pr['cultura']*1.0)*rem*0.8*surv
                            if mode=='sopra':
                                h=len(stack[cc0])                     # altezza attuale della colonna
                                VB={0:VBONUS[1],1:VBONUS[2],2:VBONUS[3],3:VBONUS[4]}
                                v+=(VB.get(min(h,3),9)-VB.get(min(max(h-1,0),3),0))*0.5
                                for c_ in range(cc0,cc1):
                                    l_,sup=ground_level(c_,pl.i)
                                    if sup is None: continue
                                    if sup.state=='intact':
                                        # perdo rendita futura e scavo di ciò che spiano
                                        v-=sup.card.get('r',0)*rem*0.6
                                    else:
                                        v+=sup.card.get('scavo',0)*SCAVOX*(1.0 if sup.owner==pl.i else 0.3)
                            # continuità di luogo: seconda carta di classe mia in colonna
                            mine=Counter()
                            for e2 in range(1,6):
                                b2=rail[e2][cc0]
                                if b2 and b2.owner==pl.i:
                                    for cl in classes(b2.card): mine[cl]+=1
                            for b2 in stack[cc0]:
                                if b2.owner==pl.i:
                                    for cl in classes(b2.card): mine[cl]+=1
                            if any(mine[cl]>=1 for cl in classes(card)): v+=2.0
                            v-=extra*0.9                              # terrapieno / spianamento
                            st_=pl.strat
                            if st_=='RENDITA': v+=rr*rem*0.5
                            if st_=='LAMPO': v+=card.get('l',0)*0.5
                            if st_=='SCAVO': v+=card.get('scavo',0)*0.6+(1.0 if mode=='sopra' else 0)
                            if st_=='VERTICALE' and mode=='sopra': v+=2.5
                            opts.append((v,card,mode,cc0,cc1,lv,nv,tot_p,Oc))
                # valore del reclutamento come opzione reale
                recl_v=-99
                if pl.oro>=1:
                    rem=(5-era)
                    # un personaggio vale: effetto medio d'era + prospettiva riesumazione
                    base_ab = 1.6 + 0.25*era              # abilità: cresce con l'era
                    SC={1:3,2:2,3:1,4:1,5:1}
                    ries = (0.5*(SC[era] if RIES_CAL else ((6-era) if RIES_INV else era))) if RIESUMA else 0
                    recl_v = base_ab + ries - 1.0          # meno il costo in oro
                    if pl.strat=='BILANCIATO': recl_v+=0.4
                opts.sort(key=lambda o:-o[0])

                if opts and recl_v>opts[0][0]:
                    pl.oro-=1; st['recl_tot']+=1
                    # assegna a un proprio edificio in piedi: preferisce quello più probabile da sotterrare
                    cand=[b for b in all_b if b.owner==pi and b.state=='intact' and b.sk is None]
                    if cand:
                        tgt=min(cand,key=lambda b:(b.lvl, b.card.get('res',0)))
                        tgt.sk=era; st['sk_ass']+=1
                    else:
                        pl.recl.append(era)
                    continue
                if (not opts) and recl_v>0 and pl.oro>=1:
                    pl.oro-=1; st['recl_tot']+=1
                    cand=[b for b in all_b if b.owner==pi and b.state=='intact' and b.sk is None]
                    if cand:
                        tgt=min(cand,key=lambda b:(b.lvl, b.card.get('res',0)))
                        tgt.sk=era; st['sk_ass']+=1
                    st['noplace']+=1
                    continue
                if not opts:
                    st['noplace']+=1
                    # diagnosi: perché non si può costruire?
                    aff=[c for c in market if pl.pietra>=cost(c)[0] and pl.oro>=cost(c)[1]]
                    if not aff:
                        st['nb_costo']+=1
                        tot=pl.pietra+pl.oro
                        poor=True; mism=False; onlyO=False; onlyP=False
                        for card in market:
                            cP,cO=cost(card)
                            if cP+cO<=tot:
                                poor=False
                                if pl.pietra<cP and pl.oro>=cO: onlyP=True
                                elif pl.oro<cO and pl.pietra>=cP: onlyO=True
                                else: mism=True
                        if poor: st['nb_poverta']+=1
                        elif onlyO and not onlyP: st['nb_oro']+=1
                        elif onlyP and not onlyO: st['nb_pietra']+=1
                        else: st['nb_mismatch']+=1
                    else:
                        capblock=False; terrblock=True; spazio=True
                        for card in aff:
                            for c0 in range(NC):
                                if can_build(card,era,c0,pl,'rail'): spazio=False
                                sav=globals().get('ERACAP')
                                globals()['ERACAP']=False
                                r2=can_build(card,era,c0,pl,'sopra')
                                globals()['ERACAP']=sav
                                if r2 and not can_build(card,era,c0,pl,'sopra'): capblock=True
                                tr=ter_req(card)
                                if tr is None: terrblock=False
                        if capblock: st['nb_cap']+=1
                        elif terrblock: st['nb_terreno']+=1
                        elif spazio: st['nb_spazio']+=1
                        else: st['nb_mercato']+=1
                    # ripiego: potenzia un proprio edificio in piedi, oppure recluta
                    if EMERG and not emerg_used.get(pi):
                        emerg_used[pi]=True
                        if pl.pietra>=2 and pl.oro<2: pl.pietra-=2; pl.oro+=1
                        elif pl.oro>=1: pl.oro-=1; pl.pietra+=2
                    ucost=1 if era<=3 else 2
                    mineb=[b for e2 in range(1,6) if rail[e2][col] for b in [rail[e2][col]] if b.owner==pi and b.state=='intact']
                    mineb+=[b for b in stack[col] if b.owner==pi and b.state=='intact']
                    if mineb and pl.oro>=ucost:
                        pl.oro-=ucost
                        t=max(mineb,key=lambda b:b.card.get('r',0))
                        if pl.strat=='RENDITA': t.bonus+=1
                        else: pl.score['lampo']+=2
                    elif pl.oro>=1 and not pl.din and era<=4:
                        pl.oro-=1; pl.score['lampo']+=1; pl.recl.append(era)
                    continue
                v,card,mode,c0,c1,lv,nv,tot_p,Oc=opts[0]
                pl.pietra-=tot_p; pl.oro-=Oc
                b=B(card,pi,era,c0,c1,lv if mode=='sopra' else 0)
                st['BUILD_'+terr[c0]]+=1
                if terr[c0]=='collina': b.bonus+=1
                if SPOL=='B' and mode=='sopra':
                    _ns=sum(1 for c_ in range(c0,c1) for x in [ground_level(c_,pi)[1]] if x is not None and x.state=='intact')
                    b.bonus+=min(_ns,1)
                if UNIQ:
                    e0=EFF[c0]; st['build_'+e0]+=1
                    if e0=='panoramica': b.bonus+=1; st['uso_panoramica']+=1
                    if e0=='sacro' and (classes(card) & {'REL','CUL'}): b.bonus+=1; st['uso_sacro']+=1
                    if e0=='castello' and not castello_used.get((pi,era)):
                        b.bonus+=1; castello_used[(pi,era)]=True; st['uso_castello']+=1
                if mode=='rail':
                    for c in range(c0,c1): rail[era][c]=b
                else:
                    st['sopra']+=1; st['terrap']+=nv
                    for c in range(c0,c1):
                        l,sup=ground_level(c,pi)
                        if sup is not None:
                            if sup.state=='intact':
                                st['rperso_spi']+=sup.card.get('r',0)*max(0,5-era)
                                st['spian']+=1
                                if sup.card.get('r'): st['spian_rend']+=1
                            else: st['rperso_sot']+=sup.card.get('r',0)*max(0,5-era)
                            sup.state=('spianata' if sup.state=='intact' else 'sotterrata'); sup.buried_on.append(b); st['buried']+=1
                            if any(cl in classes(sup.card) for cl in classes(card)): b.bonus+=1
                        stack[c].append(b)
                    st['maxlvl']=max(st['maxlvl'],b.lvl)
                    for _c in range(c0,c1): risen.add(_c)
                all_b.append(b); pl.builds+=1; st['built']+=1
                market.remove(card)
                if decks[era]: market.append(decks[era].pop())
        # evento
        if era<5:
            kind,par=ev
            live=[b for b in all_b if b.state in ('intact','rudere')]
            seen=set()
            for b in live:
                if id(b) in seen: continue
                seen.add(id(b))
                mod=0
                if kind=='terr' and any(terr[c]==par[0] for c in range(b.c0,b.c1)): mod=par[1]
                if kind=='class':
                    for cl,dv in par.items():
                        if cl in classes(b.card): mod+=dv
                if kind=='largo' and span(b.card)>=2: mod=par
                if kind=='unprot' and b.prot==0: mod=par
                if kind=='crowd': mod=par if len(stack[b.c0])>=2 else 0
                if kind=='scavo' and b.card.get('scavo',0)>=2: mod=par
                eff=b.card.get('res',0)+b.bonus+b.prot+mod-(2 if b.state=='rudere' else 0)
                if eff<FORCE[era]:
                    if b.state=='intact' and FORCE[era]-eff==1:
                        b.state='rudere'; st['ruderi']+=1; st['rperso_ev']+=b.card.get('r',0)*max(0,5-era)
                    else:
                        b.state='rovina'; st['rovine']+=1; st['rperso_ev']+=b.card.get('r',0)*max(0,5-era)
                else:
                    b.vet=min(b.vet+1,3)
            for b in all_b:
                if b.state=='intact' and b.card.get('r'):
                    players[b.owner].score['rendita']+=b.card['r']+b.vet; st['rbase']+=b.card['r']; st['rvet']+=b.vet; st['rend_eff']+=b.card['r']+b.vet
                b.prot=0
            for pl in players:
                tot=pl.pietra+pl.oro
                cap_now = (7 if (CAPDIFF and era>=4) else RESCAP)
                if tot>cap_now:
                    cut=tot-cap_now; t=min(cut,pl.pietra); pl.pietra-=t; cut-=t; pl.oro-=cut
    # finale
    for b in all_b:
        pl=players[b.owner]
        if b.state=='intact':
            if b.card.get('r'): pl.score['rendita']+=b.card['r']+b.vet; st['rbase']+=b.card['r']; st['rvet']+=b.vet; st['rend_eff']+=b.card['r']+b.vet
            pl.score['lampo']+=b.card.get('l',0)
        elif b.state in ('sotterrata','spianata'):
            pl.score['scavo']+= (0 if b.state=='spianata' else b.card.get('scavo',0)*SCAVOX)
            pl.score['lampo']+=b.card.get('l',0)
        else:
            pl.score['lampo']+=b.card.get('l',0)
    # catene = VERTICALITÀ: livelli impilati nella colonna (base + sopraelevazioni)
    for c in range(NC):
        h=len(stack[c]) + (collina_base(c) if (COLLIVELLO and COLLPUNTI) else 0)
        if h<1: continue
        bonus=VBONUS.get(min(h,4),VBONUS[4])
        st['lev%d'%min(h,5)]+=1
        cnt=Counter()
        for e in range(1,6):
            if rail[e][c]: cnt[rail[e][c].owner]+=1
        for b in stack[c]: cnt[b.owner]+=1
        tot=sum(cnt.values())
        if VMODE=='A':
            for ow in cnt: players[ow].score['catene']+=bonus/len(cnt)
        elif VMODE=='B':
            for ow,n in cnt.items(): players[ow].score['catene']+=bonus*n/max(1,tot)
        else:
            topb=stack[c][-1] if stack[c] else None
            if topb is not None: players[topb.owner].score['catene']+=bonus*0.5
            for ow,n in cnt.items(): players[ow].score['catene']+=bonus*0.5*n/max(1,tot)
        if len(cnt)>1:
            mn=min(cnt.values())
            if mn==1: st['freerider']+=1
        st['h%d'%min(h,4)]+=1
    st['hmax']=max([len(stack[c]) for c in range(NC)]+[0])
    st['lv4game']=1 if st['hmax']>=4 else 0
    if CONT:
        for c in range(NC):
            for pl in players:
                cc=Counter()
                for e in range(1,6):
                    b=rail[e][c]
                    if b and b.owner==pl.i:
                        for cl in classes(b.card): cc[cl]+=1
                for b in stack[c]:
                    if b.owner==pl.i:
                        for cl in classes(b.card): cc[cl]+=1
                if cc:
                    mx=max(cc.values())
                    if mx>=3: pl.score['continuita']+=5
                    elif mx>=2: pl.score['continuita']+=2
    if SKEL:
        for b in all_b:
            if b.sk is not None and b.state in ('sotterrata','spianata'):
                v=6-b.sk
                players[b.owner].score['riesuma']+=v
                st['sk_trov']+=1; st['sk_pv']+=v
    if RIESUMA:
        for pl in players:
            sot=sum(1 for b in all_b if b.owner==pl.i and b.state in ('sotterrata','spianata'))
            n=min(sot, len(pl.recl), RIES_MAX)
            if n>0:
                SCALA={1:3,2:2,3:1,4:1,5:1}
                vals=sorted((SCALA[e] if RIES_CAL else ((6-e) if RIES_INV else e)) for e in pl.recl)
                vals=vals[::-1][:n]
                pl.score['riesuma']+=sum(vals)
                st['ries_n']+=n; st['ries_pv']+=sum(vals)
    w=max(players,key=lambda p:p.total)
    return players,w,st

def batch(n,g,NC=10,TERRAP=1):
    STR=['RENDITA','LAMPO','SCAVO','VERTICALE','BILANCIATO']
    a={'wins':Counter(),'plays':Counter(),'tot':[],'st':Counter(),'chan':defaultdict(list)}
    for i in range(g):
        strats=random.Random(5000+i).sample(STR,min(n,5))
        pls,win,st=run(n,strats,seed=i*13+n,NC=NC,TERRAP=TERRAP)
        a['wins'][win.strat]+=1
        for p in pls:
            a['plays'][p.strat]+=1; a['tot'].append(p.total)
            for k in ('lampo','rendita','scavo','catene','continuita','riesuma'): a['chan'][k].append(p.score[k])
        a['st'].update(st)
    return a

if __name__=='__main__':
    import sys
    n=int(sys.argv[1]); g=int(sys.argv[2]); terrap=int(sys.argv[3]) if len(sys.argv)>3 else 1
    import ast
    globals()['VBONUS']=ast.literal_eval(sys.argv[4]) if len(sys.argv)>4 else {1:1,2:3,3:6,4:9}
    globals()['SCAVOX']=float(sys.argv[5]) if len(sys.argv)>5 else 1.0
    random.seed(7)
    globals()['NCOL']=int(sys.argv[6]) if len(sys.argv)>6 else 10
    globals()['ERACAP']=(len(sys.argv)>7 and sys.argv[7]=='1')
    globals()['CONT']=not (len(sys.argv)>8 and sys.argv[8]=='0')
    globals()['VMODE']=sys.argv[9] if len(sys.argv)>9 else 'A'
    globals()['RESCAP']=int(sys.argv[10]) if len(sys.argv)>10 else 5
    globals()['EMERG']=(len(sys.argv)>11 and sys.argv[11]=='1')
    globals()['FLEX']=sys.argv[12] if len(sys.argv)>12 else 'none'
    globals()['CAPDIFF']=(len(sys.argv)>13 and sys.argv[13]=='1')
    globals()['SPEC']=int(sys.argv[14]) if len(sys.argv)>14 else 2
    globals()['S2']=(len(sys.argv)>15 and sys.argv[15]=='1')
    globals()['PROSP']=(len(sys.argv)>16 and sys.argv[16]=='1')
    globals()['LISTINO']=(len(sys.argv)>17 and sys.argv[17]=='1')
    globals()['RIESUMA']=(len(sys.argv)>25 and sys.argv[25]!='0')
    globals()['RIES_INV']=(len(sys.argv)>25 and sys.argv[25]=='2')
    globals()['SKEL']=(len(sys.argv)>28 and sys.argv[28]=='1')
    globals()['SPOL']=sys.argv[27] if len(sys.argv)>27 else ''
    globals()['RIES_CAL']=(len(sys.argv)>25 and sys.argv[25]=='3')
    globals()['RIES_MAX']=int(sys.argv[26]) if len(sys.argv)>26 else 3
    globals()['W_P']=1.0 if (len(sys.argv)>24 and sys.argv[24]=='1') else 0.8
    globals()['W_O']=1.0 if (len(sys.argv)>24 and sys.argv[24]=='1') else 1.2
    globals()['COSTI_A']=(len(sys.argv)>23 and sys.argv[23]=='1')
    globals()['FIUMEPROP']=(len(sys.argv)>22 and sys.argv[22]=='1')
    globals()['MERCATO']=(len(sys.argv)>21 and sys.argv[21]=='1')
    globals()['UNIQ']=(len(sys.argv)>20 and sys.argv[20]=='1')
    globals()['TERR2']=(len(sys.argv)>19 and sys.argv[19]=='1')
    globals()['COLLIVELLO']=(len(sys.argv)>18 and sys.argv[18]!='0')
    globals()['COLLPUNTI']=(len(sys.argv)>18 and sys.argv[18]=='2')
    a=batch(n,g,NC=NCOL,TERRAP=terrap)
    print(f'--- {n} giocatori, {g} partite, terrapieno={terrap}P ---')
    for s in ('RENDITA','LAMPO','SCAVO','VERTICALE','BILANCIATO'):
        if a['plays'][s]:
            w=a['wins'][s]/a['plays'][s]
            print(f"  {s:11s} {100*w:5.1f}% ±{196*(w*(1-w)/a['plays'][s])**0.5:3.1f}")
    st=a['st']
    print(f"  PV medi {S.mean(a['tot']):.1f} · costruiti/partita {st['built']/g:.1f}")
    print(f"  Costruzioni SOPRA: {100*st['sopra']/max(1,st['built']):.1f}% · slot di terrapieno/partita {st['terrap']/g:.2f}")
    print(f"  Rendita — base teorica {st['rteo']/g:.1f} · base incassata {st['rbase']/g:.1f} · vetustà {st['rvet']/g:.1f} · ratio base {st['rbase']/max(1,st['rteo']):.2f}")
    KEYS=['cantieri','mercato','cereali','strade','castello','cave','panoramica','sacro','caccia','altofusto','porto','guado']
    if any(st['pres_'+k] for k in KEYS):
        print("  DIAGNOSTICA COLONNE (per partita in cui è presente):")
        print("   colonna        presenza  attivaz.  costruz.  usi effetto  valore")
        for k in KEYS:
            p=st['pres_'+k]
            if not p: continue
            print(f"   {k:13s} {100*p/g:5.0f}%   {st['att_'+k]/p:6.2f}   {st['build_'+k]/p:6.2f}    {st['uso_'+k]/p:7.2f}   {st['val_'+k]/p:6.2f}")
    TT=['pianura','collina','bosco','fiume']
    tot_att=sum(st['ATT_'+t] for t in TT) or 1
    print("  TERRENI — attivazioni per colonna presente · quota attivazioni · proprietà · produzione per attivazione")
    for t in TT:
        nc_=st['NCOL_'+t] or 1; at=st['ATT_'+t] or 1
        print(f"   {t:9s} att/colonna {at/nc_:6.2f} · quota {100*st['ATT_'+t]/tot_att:5.1f}% · possiede già {100*st['OWN_'+t]/at:4.0f}% · base {st['BASE_P_'+t]/at:.2f}P+{st['BASE_O_'+t]/at:.2f}O · rendite {st['REND_P_'+t]/at:.2f}P+{st['REND_O_'+t]/at:.2f}O · prosp {st['PROSP_'+t]/at:.2f}O · costruz/colonna {st['BUILD_'+t]/nc_:.2f}")
    if st['merc_uso']:
        print(f"  MERCATO: {st['merc_uso']/g:.2f} conversioni/partita · necessarie {100*st['merc_necessario']/st['merc_uso']:.0f}% · opportunistiche {100*st['merc_opportunistico']/st['merc_uso']:.0f}%")
        print("    per era: " + " · ".join("e%d %.2f"%(e,st['merc_era%d'%e]/g) for e in range(1,6)))
        print("    per terreno: " + " · ".join("%s %.2f"%(t,st['merc_'+t]/g) for t in ('pianura','collina','bosco')))
        print(f"    pietra consumata {2*st['merc_uso']/g:.1f} · oro prodotto {st['merc_uso']/g:.1f}")
    print("  TERRENI per era (quota % delle attivazioni):")
    for e in range(1,6):
        tote=sum(st['ATTera%d_%s'%(e,t)] for t in TT) or 1
        print("   era %d: "%e + " · ".join(f"{t[:4]} {100*st['ATTera%d_%s'%(e,t)]/tote:4.1f}%" for t in TT))
    print(f"  Scheletri: assegnati {st['sk_ass']/g:.2f} · ritrovati {st['sk_trov']/g:.2f} ({100*st['sk_trov']/max(1,st['sk_ass']):.0f}%) · PV {st['sk_pv']/g:.2f}")
    print(f"  Reclutamenti: {st['recl_tot']/g:.2f}/partita")
    print(f"  Riesumazioni: {st['ries_n']/g:.2f}/partita · PV {st['ries_pv']/g:.2f}")
    print(f"  Prosperità: {st['oro_prosp']/g:.1f} oro/partita ({st['oro_passivo']/g:.1f} passivo agli avversari) · attivazioni di Centri {st['centri_att']/g:.1f}")
    print(f"  Spianamenti: {st['spian']/g:.2f}/partita, di cui con Rendita {st['spian_rend']/g:.2f}")
    print(f"  Rendita persa — evento {st['rperso_ev']/g:.1f} · sotterramento {st['rperso_sot']/g:.1f} · spianamento {st['rperso_spi']/g:.1f}")
    print(f"  Flex: acquisti abilitati {st['flexbuy']/g:.1f}/partita, conversioni {st['flexuse']/g:.1f} (P→O {st['flex_p2o']/g:.1f}, O→P {st['flex_o2p']/g:.1f})")
    print(f"  Flex usati: {st['flexuse']/g:.2f}/partita · Realization ratio Rendita: {st['rend_eff']/max(1,st['rend_teo']):.2f}")
    print(f"  Turni senza alcuna costruzione possibile: {100*st['noplace']/max(1,st['turns']):.1f}%")
    tot_nb=max(1,st['noplace'])
    nbc=max(1,st['nb_costo'])
    print("    dentro COSTO:", {k: f"{100*st['nb_'+k]/nbc:.0f}%" for k in ('poverta','mismatch','oro','pietra')})
    print("    cause:", {k: f"{100*st['nb_'+k]/tot_nb:.0f}%" for k in ('costo','cap','spazio','terreno','mercato')})
    print(f"  Ruderi {st['ruderi']/g:.1f}/partita · rovine {st['rovine']/g:.1f} · sotterrati {st['buried']/g:.1f}")
    print("  Colonne per livello:", {k: round(st['lev%d'%k]/g,2) for k in range(0,6)})
    print(f"  Partite con livello 4+: {100*st['lv4game']/g:.0f}% · colonne con free rider (1 solo edificio): {st['freerider']/g:.2f}/partita")
    print(f"  Altezza massima media: {st['hmax']/g:.2f}")
    print(f"  Colonne per altezza/partita: 1 liv {st['h1']/g:.2f} · 2 liv {st['h2']/g:.2f} · 3 liv {st['h3']/g:.2f} · 4+ {st['h4']/g:.2f}")
    for k in ('lampo','rendita','scavo','catene','continuita','riesuma'):
        print(f"    {k:8s} {S.mean(a['chan'][k]):5.1f} PV")
