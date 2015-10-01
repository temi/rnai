drop database rnai;
create database rnai;
\c rnai;
create table genome(
  id serial primary key,
  filename varchar default null,
  title varchar(255) not null,
  parentid int references genome(id) default null
);
create table query(
  id serial primary key,
  queryname varchar(255) not null,
  query text not null,
  status varchar(50) not null,
  mismatch int not null,
  mersize int not null,
  submittime timestamp not null,
  md5 varchar(32) not null,
  completetime timestamp
);
create table hits(
  md5 varchar(32) not null,
  dbid int not null references genome(id),
  hits int not null,
  primary key (dbid,md5)
);
create table regions(
  id serial primary key,
  dbid int not null references genome(id),
  md5 varchar(32) not null,
  starting int not null,
  ending int not null,
  mismatches varchar(255) 
);
insert into genome(id,filename,title) values(0,NULL,'Eukaryota');
ALTER SEQUENCE genome_id_seq INCREMENT 1;
insert into genome(filename,title,parentid) values('ACPmRNA','Acyrthosiphon pisum',0);
insert into genome(filename,title,parentid) values('Myzus_persicae.fa','Myzus persicae',0);
insert into genome(filename,title,parentid) values('Sitobion_avenae.fasta','Sitobion avenae',0);
insert into genome(filename,title,parentid) values('Brevi_TX.fa','Brevicoryne brassica',0);
insert into genome(filename,title,parentid) values('Brara_mRNA.fa','Brassica rapa',0);
insert into genome(filename,title,parentid) values('Plutella_xylostella.fa','Plutella xylostella',0);
insert into genome(filename,title,parentid) values('Chicken_rna.fa','Gallus gallus',0);
insert into genome(filename,title,parentid) values('ATH_cDNA.fa','Arabidopsis thaliana',0);
insert into genome(filename,title,parentid) values('Homo_mRNA.fa','Homo sapiens',0);
insert into genome(filename,title,parentid) values('Rn_TX.fa','Rattus norvegicus',0);
insert into genome(filename,title,parentid) values('Mm_TX.fa','Mus musculus',0);
insert into genome(filename,title,parentid) values('Ta_TX.fa','Loxodonta africana',0);
insert into genome(filename,title,parentid) values('Oa_TX.fa','Ornithorhynchus anatinus ',0);
insert into genome(filename,title,parentid) values('AECHI_Aech_v3_8_cds.fa','Acromyrmex echinatior',0);
insert into genome(filename,title,parentid) values('aedes_aegypti_transcripts_AaegL1.2.fa','Aedes aegypti',0);
insert into genome(filename,title,parentid) values('AGAMB_transcripts_AgamP3_6.fa','Anopheles gambiae',0);
insert into genome(filename,title,parentid) values('AMEL_Amel_pre_release2_OGS_cds.fa','Apis mellifera',0);
insert into genome(filename,title,parentid) values('Aphis_gossypii_contig.fa','Aphis gossypii',0);
insert into genome(filename,title,parentid) values('Bemisia_tabaci.fa','Bemisia tabaci',0);
insert into genome(filename,title,parentid) values('BMORI_silkcds.fa','Bombyx mori',0);
insert into genome(filename,title,parentid) values('Bombus_terrestris.fa','Bombus terrestris',0);
insert into genome(filename,title,parentid) values('Celuca_puligator.fa','Celuca puligator',0);
insert into genome(filename,title,parentid) values('Cypridininae_sp.fa','Cypridininae sp',0);
insert into genome(filename,title,parentid) values('Dendroctonus_ponderosae_contig.fa','Dendroctonus ponderosae',0);
insert into genome(filename,title,parentid) values('DMELA_dmel_all_CDS_r5_40.fa','Drosophila melanogaster',0);
insert into genome(filename,title,parentid) values('DPULE_dpulex_aug26_mixin19an5_cds.fa','Daphnia pulex',0);
insert into genome(filename,title,parentid) values('Exoneura_robusta.fa','Exoneura robusta',0);
insert into genome(filename,title,parentid) values('Glomeris_pustulata_me200_Vec_cleaned.fa','Glomeris pustulata',0);
insert into genome(filename,title,parentid) values('Glossina_morsitans_morsitans_contig.fa','Glossina morsitans',0);
insert into genome(filename,title,parentid) values('ISCAP_ixodes_scapularis_transcripts_IscaW1_1.fa','Ixodes scapularis',0);
insert into genome(filename,title,parentid) values('Lepeophtheirus_salmonis.fa','Lepeophtheirus salmonis',0);
insert into genome(filename,title,parentid) values('Litopenaeus_vannamei.fa','Litopenaeus vannamei',0);
insert into genome(filename,title,parentid) values('Manduca_sexta.fa','Manduca sexta',0);
insert into genome(filename,title,parentid) values('NVITR_Nvit_OGS_v1_2_rna.fa','Nasonia vitripennis',0);
insert into genome(filename,title,parentid) values('Phlebotomus_papatasi_contig.fa','Phlebotomus papatasi',0);
insert into genome(filename,title,parentid) values('PHUMA_pediculus_humanus_transcripts_PhumU1_2.fa','Pediculus humanus',0);
insert into genome(filename,title,parentid) values('Rhagoletis_pomonella.fa','Rhagoletis pomonella',0);
insert into genome(filename,title,parentid) values('Sarcophaga_crassipalpis.fa','Sarcophaga crassipalpis',0);
insert into genome(filename,title,parentid) values('Sarsinebalia_urgorii.fa','Sarsinebalia urgorii',0);
insert into genome(filename,title,parentid) values('Speleonectes_tulumensis.fa','Speleonectes tulumensis',0);
insert into genome(filename,title,parentid) values('Symphylella_vulgaris_me200_Vec_cleaned.fa','Symphylella vulgaris',0);
insert into genome(filename,title,parentid) values('TCAST_Tcas_3_0_OGS_CDS.fa','Tribolium castaneum',0);
insert into genome(filename,title,parentid) values('ZNEVA_Znev_OGS_v2_1_cds.fa','Zootermopsis nevadensis',0);
insert into genome(filename,title,parentid) values('Arer_N_me200_cleaned.fa','Archaeopsylla erinacei',0);
insert into genome(filename,title,parentid) values('Cagr_N_me200_cleaned.fa','Carabus granulatus',0);
insert into genome(filename,title,parentid) values('hsal_v3_3_cds.fa','Harpegnathos saltator',0);
insert into genome(filename,title,parentid) values('Memo_N_me200_cleaned.fa','Mengenilla moldrzyki',0);
insert into genome(filename,title,parentid) values('Mica_N_me200_cleaned.fa','Micropterix calthella',0);
insert into genome(filename,title,parentid) values('Phlu_N_me200_cleaned.fa','Philopotamus ludificatus',0);
insert into genome(filename,title,parentid) values('Prse_N_me200_cleaned.fa','Priacma serrata',0);
insert into genome(filename,title,parentid) values('Silu_N_me200_cleaned.fa','Sialis lutaria',0);
insert into genome(filename,title,parentid) values('Tima_N_me200_cleaned.fa','Tipula maxima',0);
insert into genome(filename,title,parentid) values('111015_I297_FCD05HRACXX_L8_INSbttTARAAPEI-9.tsa.fas','Platycentropus radiatus',0);
insert into genome(filename,title,parentid) values('111015_I297_FCD05HRACXX_L1_INSbttTARAAPEI-83.tsa.fas','Bittacus pilicornis',0);
insert into genome(filename,title,parentid) values('111015_I297_FCD05HRACXX_L1_INSbttTIRAAPEI-18.tsa.fas','Folsomia candida',0);
insert into genome(filename,title,parentid) values('111015_I297_FCD05HRACXX_L1_INSbttTJRAAPEI-19.tsa.fas','Tricholepidion gertschi',0);
insert into genome(filename,title,parentid) values('111015_I297_FCD05HRACXX_L8_INSbttTKRAAPEI-18.tsa.fas','Corydalus cornutus',0);
insert into genome(filename,title,parentid) values('111015_I297_FCD05HRACXX_L8_INSbttTSRAAPEI-29.tsa.fas','Thermobia domestica',0);
insert into genome(filename,title,parentid) values('110817_I809_FCD05CDACXX_L3_INSbusTBCRABPEI-135.tsa.fas','Bibio marci',0);
insert into genome(filename,title,parentid) values('110817_I809_FCD05CDACXX_L3_INSbusTBDRAAPEI-79.tsa.fas','Dyseriocrania subpurpurella',0);
insert into genome(filename,title,parentid) values('110817_I809_FCD05CDACXX_L3_INSbusTBKRAAPEI-76.tsa.fas','Bombylius major',0);
insert into genome(filename,title,parentid) values('110817_I809_FCD05CDACXX_L3_INSbusTBMRAAPEI-78.tsa.fas','Prorhinotermes simplex',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTAARAAPEI-19.tsa.fas','Periplaneta americana',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTAFRAAPEI-31.tsa.fas','Menopon gallinae',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L3_INSfrgTAHRAAPEI-18.tsa.fas','Epiophlebia superstes',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L3_INSfrgTAKRAAPEI-21.tsa.fas','Galloisiana yuasai',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L2_INSfrgTALRAAPEI-22.tsa.fas','Apachyus charteceus',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L3_INSfrgTAORAAPEI-33.tsa.fas','Peruphasma schultei',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTAPRAAPEI-33.tsa.fas','Trialeurodes vaporariorum',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTASRAAPEI-36.tsa.fas','Empusa pennata',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTATRAAPEI-37.tsa.fas','Tenthredo koehleri',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTAVRAAPEI-41.tsa.fas','Blaberus atropos',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSfrgTAXRABPEI-44.tsa.fas','Gryllotalpa sp',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTAZRAAPEI-46.tsa.fas','Aposthonia japonica',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTBBRAAPEI-56.tsa.fas','Tanzaniophasma sp',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L1_INSfrgTBCRAAPEI-57.tsa.fas','Nilaparvata lugens',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTAARAAPEI-90.tsa.fas','Mantis religiosa',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTABRAAPEI-93.tsa.fas','Nemophora degeerella',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTACRAAPEI-94.tsa.fas','Panorpa vulgaris',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTAFRAAPEI-9.tsa.fas','Sminthurus viridis',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L6_INShauTAJRAAPEI-89.tsa.fas','Pogonognathellus sp',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L6_INShauTAKRAAPEI-90.tsa.fas','Baetis sp',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L6_INShauTALRAAPEI-93.tsa.fas','Perla marginata',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L6_INShauTAMRAAPEI-94.tsa.fas','Metallyticus splendidus',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L6_INShauTANRAAPEI-95.tsa.fas','Tetrix subulata',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L6_INShauTAPRAAPEI-9.tsa.fas','Notostira elongata',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L6_INShauTAQRABPEI-11.tsa.fas','Chrysis viridula',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTAYRAAPEI-19.tsa.fas','Meloe violaceus',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTBERAAPEI-33.tsa.fas','Aleochara curtula',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTBFRAAPEI-34.tsa.fas','Yponomeuta evonymella',0);
insert into genome(filename,title,parentid) values('111126_I883_FCD0GUKACXX_L7_INShauTBGRAAPEI-35.tsa.fas','Polyommatus icarus',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTABRAAPEI-20.tsa.fas','Frankliniella cephalica',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTACRAAPEI-21.tsa.fas','Thrips palmi',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTADRAAPEI-22.tsa.fas','Gynaikothrips ficorum',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTAGRAAPEI-33.tsa.fas','Isonychia bicolor',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTAHRAAPEI-34.tsa.fas','Acerentomon sp',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTAIRAAPEI-35.tsa.fas','Planococcus citri',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTAJRAAPEI-36.tsa.fas','Parides eurimedes',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L6_INSjdsTAKRAAPEI-37.tsa.fas','Tetrodontophora bielanensis',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L7_INSjdsTAQRAAPEI-46.tsa.fas','Zorotypus caudelli',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L8_INSjdsTARRAAPEI-47.tsa.fas','Xenophysella greensladeae',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L7_INSjdsTATRAAPEI-57.tsa.fas','Euroleon nostras',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L7_INSjdsTAURAAPEI-62.tsa.fas','Leptopilina clavipes',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L7_INSjdsTAVRAAPEI-37.tsa.fas','Atelura formicaria',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L7_INSjdsTAWRAAPEI-39.tsa.fas','Zygaena fausta',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L8_INSjdsTBERAAPEI-56.tsa.fas','Trichocera saltator',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L8_INSjdsTBHRAAPEI-74.tsa.fas','Cordulegaster boltonii',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L8_INSjdsTBJRAAPEI-79.tsa.fas','Osmylus fulvicephalus',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L8_INSjdsTBNRAAPEI-89.tsa.fas','Forficula auricularia',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L8_INSjdsTBQRAAPEI-94.tsa.fas','Conwentzia psociformis',0);
insert into genome(filename,title,parentid) values('120215_I277_FCD0KP1ACXX_L7_INSjdsTBSRAAPEI-9.tsa.fas','Rhyacophila fasciata',0);
insert into genome(filename,title,parentid) values('120107_I247_FCD0KMHACXX_L8_INSnfrTAARAAPEI-13.tsa.fas','Orussus abietinus',0);
insert into genome(filename,title,parentid) values('120107_I247_FCD0KMHACXX_L8_INSnfrTAFRAAPEI-18.tsa.fas','Meinertellus cundinamarcensis',0);
insert into genome(filename,title,parentid) values('120107_I247_FCD0KMHACXX_L8_INSnfrTAGRAAPEI-19.tsa.fas','Xanthostigma xanthostigma',0);
insert into genome(filename,title,parentid) values('120107_I247_FCD0KMHACXX_L8_INSnfrTAIRAAPEI-21.tsa.fas','Anurida maritima',0);
insert into genome(filename,title,parentid) values('120107_I247_FCD0KMHACXX_L8_INSnfrTAJRAAPEI-22.tsa.fas','Machilis hrabei',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTAKRAAPEI-30.tsa.fas','Ephemera danica',0);
insert into genome(filename,title,parentid) values('120107_I247_FCD0KMHACXX_L8_INSnfrTALRAAPEI-31.tsa.fas','Leuctra sp',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTAMRAAPEI-33.tsa.fas','Stenobothrus lineatus',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTANRAAPEI-34.tsa.fas','Cercopis vulnerata',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTAORAAPEI-35.tsa.fas','Velia caprai',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTAPRAAPEI-36.tsa.fas','Acanthosoma haemorrhoidale',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTAQRAAPEI-37.tsa.fas','Cotesia vestalis',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTARRAAPEI-39.tsa.fas','Pseudomallada prasinus',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L1_INSnfrTAVRAAPEI-9.tsa.fas','Triodia sylvina',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L3_INSnfrTBARAAPEI-15.tsa.fas','Ceratophyllus gallinae',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L2_INSnfrTBERAAPEI-19.tsa.fas','Gyrinus marinus',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L2_INSnfrTBFRAAPEI-90.tsa.fas','Triarthria setipennis',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L2_INSnfrTBIRAAPEI-95.tsa.fas','Ceuthophilus sp',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L2_INSnfrTBJRAAPEI-8.tsa.fas','Hydroptila sp',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L3_INSnfrTBKRAAPEI-9.tsa.fas','Grylloblatta bifratrilecta',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L3_INSnfrTBLRAAPEI-11.tsa.fas','Okanagana villosa',0);
insert into genome(filename,title,parentid) values('120126_I283_FCD0L80ACXX_L2_INSnfrTBPRAAPEI-15.tsa.fas','Timema cristinae',0);
insert into genome(filename,title,parentid) values('120403_I266_FCC0H3RACXX_L2_INStmbTAARAAPEI-84.tsa.fas','Calopteryx splendens',0);
insert into genome(filename,title,parentid) values('120403_I266_FCC0H3RACXX_L2_INStmbTABRAAPEI-87.tsa.fas','Campodea augens',0);
insert into genome(filename,title,parentid) values('120316_I251_FCC0HJ1ACXX_L8_INStmbTAWRAAPEI-13.tsa.fas','Boreus hyemalis',0);
insert into genome(filename,title,parentid) values('120403_I266_FCC0H3RACXX_L2_INStmbTAYRAAPEI-17.tsa.fas','Ctenocephalides felis',0);
insert into genome(filename,title,parentid) values('120429_I266_FCC0HG0ACXX_L7_INStmbTBCRBAPEI-33.tsa.fas','Prosarthria teretrirostris',0);
insert into genome(filename,title,parentid) values('120403_I266_FCC0H3RACXX_L3_INStmbTBERAAPEI-30.tsa.fas','Aretaon asperrimus',0);
insert into genome(filename,title,parentid) values('120403_I266_FCC0H3RACXX_L3_INStmbTBFRAAPEI-31.tsa.fas','Cosmioperla kuna',0);
insert into genome(filename,title,parentid) values('120403_I266_FCC0H3RACXX_L3_INStmbTBGRAAPEI-33.tsa.fas','Liposcelis bostrychophila',0);
insert into genome(filename,title,parentid) values('120429_I266_FCC0HG0ACXX_L8_INStmbTBPRAAPEI-20.tsa.fas','Mastotermes darwiniensis',0);
insert into genome(filename,title,parentid) values('120429_I266_FCC0HG0ACXX_L8_INSytvTAHRAAPEI-17.tsa.fas','Haploembia palaui',0);
insert into genome(filename,title,parentid) values('120429_I266_FCC0HG0ACXX_L8_INSytvTAJRAAPEI-19.tsa.fas','Lepicerus sp',0);
insert into genome(filename,title,parentid) values('120429_I266_FCC0HG0ACXX_L8_INSytvTALRAAPEI-35.tsa.fas','Acanthocasuarina muellerianae',0);
insert into genome(filename,title,parentid) values('120429_I266_FCC0HG0ACXX_L7_INSytvTANRAAPEI-37.tsa.fas','Ranatra linearis',0);
insert into genome(filename,title,parentid) values('120521_I249_FCC0U4RACXX_L8_INSytvTBHRAAPEI-14.tsa.fas','Essigella californica',0);
insert into genome(filename,title,parentid) values('120521_I249_FCC0U4RACXX_L7_INSytvTBKRAAPEI-43.tsa.fas','Stylops melittae',0);
insert into genome(filename,title,parentid) values('120521_I249_FCC0U4RACXX_L8_INSytvTBWRAAPEI-20.tsa.fas','Lipara lucens',0);
insert into genome(filename,title,parentid) values('120521_I249_FCC0U4RACXX_L8_INSytvTCDRAAPEI-35.tsa.fas','Cryptocercus wrighti',0);
insert into genome(filename,title,parentid) values('120521_I249_FCC0U4RACXX_L8_INSytvTCERAAPEI-36.tsa.fas','Eurylophella sp',0);
insert into genome(filename,title,parentid) values('120521_I249_FCC0U4RACXX_L8_INSytvTCFRAAPEI-37.tsa.fas','Ectopsocus briggsi',0);
insert into genome(filename,title,parentid) values('120521_I249_FCC0U4RACXX_L8_INSytvTCFRAAPEI-43.tsa.fas','Inocellia crassicornis',0);
