// Field catalogue extracted from the owner's female UI prototype.
import 'dart:convert';

final List<Map<String, dynamic>> femaleSections =
    (jsonDecode(r'''[
  {
    "id": "perfil",
    "title": "👤 1 · Perfil",
    "fields": [
      {
        "key": "identity.nombre",
        "label": "Nombre *",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "identity.apellido",
        "label": "Apellido",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "identity.apodo",
        "label": "Apodo",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "physical.edad",
        "label": "Edad",
        "type": "number",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "physical.orientacion",
        "label": "Orientación sexual",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Heterosexual",
            "label": "Heterosexual"
          },
          {
            "value": "Bisexual",
            "label": "Bisexual"
          },
          {
            "value": "Lesbiana",
            "label": "Lesbiana"
          },
          {
            "value": "Asexual",
            "label": "Asexual"
          },
          {
            "value": "Pansexual",
            "label": "Pansexual"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "physical.nacionalidad",
        "label": "Nacionalidad",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "profile.ocupacion",
        "label": "Ocupación",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Estudiante",
            "label": "Estudiante"
          },
          {
            "value": "Profesora",
            "label": "Profesora"
          },
          {
            "value": "CEO / Directiva",
            "label": "CEO / Directiva"
          },
          {
            "value": "Modelo",
            "label": "Modelo"
          },
          {
            "value": "Artista",
            "label": "Artista"
          },
          {
            "value": "Profesional de salud",
            "label": "Profesional de salud"
          },
          {
            "value": "Investigadora",
            "label": "Investigadora"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "profile.especie",
        "label": "Especie",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Humana",
            "label": "Humana"
          },
          {
            "value": "Elfa",
            "label": "Elfa"
          },
          {
            "value": "Androide",
            "label": "Androide"
          },
          {
            "value": "Demonio",
            "label": "Demonio"
          },
          {
            "value": "Ángel",
            "label": "Ángel"
          },
          {
            "value": "Híbrida",
            "label": "Híbrida"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "Humana",
        "advanced": true
      }
    ],
    "advanced": false
  },
  {
    "id": "apariencia",
    "title": "👗 2 · Apariencia",
    "fields": [
      {
        "key": "physical.piel",
        "label": "Tono de piel",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Muy clara",
            "label": "Muy clara"
          },
          {
            "value": "Clara",
            "label": "Clara"
          },
          {
            "value": "Media",
            "label": "Media"
          },
          {
            "value": "Oliva",
            "label": "Oliva"
          },
          {
            "value": "Morena",
            "label": "Morena"
          },
          {
            "value": "Oscura",
            "label": "Oscura"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "physical.complexion",
        "label": "Complexión",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Petite",
            "label": "Petite"
          },
          {
            "value": "Slim",
            "label": "Slim"
          },
          {
            "value": "Fit",
            "label": "Fit"
          },
          {
            "value": "Natural",
            "label": "Natural"
          },
          {
            "value": "Curvy",
            "label": "Curvy"
          },
          {
            "value": "Thick",
            "label": "Thick"
          },
          {
            "value": "BBW",
            "label": "BBW"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "physical.altura",
        "label": "Altura (cm)",
        "type": "number",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "physical.peso",
        "label": "Peso (kg)",
        "type": "number",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "physical.silueta",
        "label": "Silueta",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Reloj de arena",
            "label": "Reloj de arena"
          },
          {
            "value": "Pera",
            "label": "Pera"
          },
          {
            "value": "Manzana",
            "label": "Manzana"
          },
          {
            "value": "Rectángulo",
            "label": "Rectángulo"
          },
          {
            "value": "Triángulo invertido",
            "label": "Triángulo invertido"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "physical.cintura",
        "label": "Cintura (cm)",
        "type": "number",
        "multiline": false,
        "advanced": true
      },
      {
        "key": "physical.busto.copa",
        "label": "Busto · Copa",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "AAA",
            "label": "AAA"
          },
          {
            "value": "AA",
            "label": "AA"
          },
          {
            "value": "A",
            "label": "A"
          },
          {
            "value": "B",
            "label": "B"
          },
          {
            "value": "C",
            "label": "C"
          },
          {
            "value": "D",
            "label": "D"
          },
          {
            "value": "DD/E",
            "label": "DD/E"
          },
          {
            "value": "DDD/F",
            "label": "DDD/F"
          },
          {
            "value": "G",
            "label": "G"
          },
          {
            "value": "H",
            "label": "H"
          },
          {
            "value": "I",
            "label": "I"
          },
          {
            "value": "J",
            "label": "J"
          },
          {
            "value": "K",
            "label": "K"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.forma",
        "label": "Busto · Forma",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "redondeada",
            "label": "Redondeada"
          },
          {
            "value": "natural_gota",
            "label": "Natural gota"
          },
          {
            "value": "proyectada",
            "label": "Proyectada"
          },
          {
            "value": "amplia_separada",
            "label": "Amplia separada"
          },
          {
            "value": "asimetrica",
            "label": "Asimétrica"
          },
          {
            "value": "en_campana",
            "label": "En campana"
          },
          {
            "value": "tuberosa_conica",
            "label": "Tuberosa cónica"
          },
          {
            "value": "atletica",
            "label": "Atlética"
          },
          {
            "value": "ptosis_leve",
            "label": "Ptosis leve"
          },
          {
            "value": "ptosis_moderada",
            "label": "Ptosis moderada"
          },
          {
            "value": "ptosis_severa",
            "label": "Ptosis severa"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.contorno",
        "label": "Busto · Contorno (cm)",
        "type": "number",
        "multiline": false,
        "advanced": true
      },
      {
        "key": "physical.busto.underbust",
        "label": "Busto · Underbust (cm)",
        "type": "number",
        "multiline": false,
        "advanced": true
      },
      {
        "key": "physical.busto.areolas.medida",
        "label": "Areolas · Medida (cm)",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "1",
            "label": "1"
          },
          {
            "value": "2",
            "label": "2"
          },
          {
            "value": "3",
            "label": "3"
          },
          {
            "value": "4",
            "label": "4"
          },
          {
            "value": "5",
            "label": "5"
          },
          {
            "value": "6",
            "label": "6"
          },
          {
            "value": "7",
            "label": "7"
          },
          {
            "value": "8",
            "label": "8"
          },
          {
            "value": "9",
            "label": "9"
          },
          {
            "value": "10",
            "label": "10"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.areolas.color",
        "label": "Areolas · Color",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Rosa claro",
            "label": "Rosa claro"
          },
          {
            "value": "Rosa medio",
            "label": "Rosa medio"
          },
          {
            "value": "Marrón claro",
            "label": "Marrón claro"
          },
          {
            "value": "Marrón medio",
            "label": "Marrón medio"
          },
          {
            "value": "Marrón oscuro",
            "label": "Marrón oscuro"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.areolas.textura",
        "label": "Areolas · Textura",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Suave",
            "label": "Suave"
          },
          {
            "value": "Suave con leve textura",
            "label": "Suave con leve textura"
          },
          {
            "value": "Texturizada",
            "label": "Texturizada"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.areolas.detalles",
        "label": "Areolas · Detalles",
        "type": "text",
        "multiline": true,
        "advanced": true
      },
      {
        "key": "physical.busto.pezones.diametro",
        "label": "Pezones · Diámetro (cm)",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "0.8",
            "label": "0,8"
          },
          {
            "value": "0.9",
            "label": "0,9"
          },
          {
            "value": "1.0",
            "label": "1,0"
          },
          {
            "value": "1.1",
            "label": "1,1"
          },
          {
            "value": "1.2",
            "label": "1,2"
          },
          {
            "value": "1.3",
            "label": "1,3"
          },
          {
            "value": "1.4",
            "label": "1,4"
          },
          {
            "value": "1.5",
            "label": "1,5"
          },
          {
            "value": "1.6",
            "label": "1,6"
          },
          {
            "value": "1.7",
            "label": "1,7"
          },
          {
            "value": "1.8",
            "label": "1,8"
          },
          {
            "value": "1.9",
            "label": "1,9"
          },
          {
            "value": "2.0",
            "label": "2,0"
          },
          {
            "value": "2.1",
            "label": "2,1"
          },
          {
            "value": "2.2",
            "label": "2,2"
          },
          {
            "value": "2.3",
            "label": "2,3"
          },
          {
            "value": "2.4",
            "label": "2,4"
          },
          {
            "value": "2.5",
            "label": "2,5"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.pezones.proyeccion",
        "label": "Pezones · Proyección (cm)",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "0.0",
            "label": "0,0"
          },
          {
            "value": "0.1",
            "label": "0,1"
          },
          {
            "value": "0.2",
            "label": "0,2"
          },
          {
            "value": "0.3",
            "label": "0,3"
          },
          {
            "value": "0.4",
            "label": "0,4"
          },
          {
            "value": "0.5",
            "label": "0,5"
          },
          {
            "value": "0.6",
            "label": "0,6"
          },
          {
            "value": "0.7",
            "label": "0,7"
          },
          {
            "value": "0.8",
            "label": "0,8"
          },
          {
            "value": "0.9",
            "label": "0,9"
          },
          {
            "value": "1.0",
            "label": "1,0"
          },
          {
            "value": "1.1",
            "label": "1,1"
          },
          {
            "value": "1.2",
            "label": "1,2"
          },
          {
            "value": "1.3",
            "label": "1,3"
          },
          {
            "value": "1.4",
            "label": "1,4"
          },
          {
            "value": "1.5",
            "label": "1,5"
          },
          {
            "value": "1.6",
            "label": "1,6"
          },
          {
            "value": "1.7",
            "label": "1,7"
          },
          {
            "value": "1.8",
            "label": "1,8"
          },
          {
            "value": "1.9",
            "label": "1,9"
          },
          {
            "value": "2.0",
            "label": "2,0"
          },
          {
            "value": "2.1",
            "label": "2,1"
          },
          {
            "value": "2.2",
            "label": "2,2"
          },
          {
            "value": "2.3",
            "label": "2,3"
          },
          {
            "value": "2.4",
            "label": "2,4"
          },
          {
            "value": "2.5",
            "label": "2,5"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.pezones.tipo",
        "label": "Pezones · Tipo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Protuberantes",
            "label": "Protuberantes"
          },
          {
            "value": "Planos",
            "label": "Planos"
          },
          {
            "value": "Invertidos",
            "label": "Invertidos"
          },
          {
            "value": "Pseudoinvertidos",
            "label": "Pseudoinvertidos"
          },
          {
            "value": "Unilaterales",
            "label": "Unilaterales"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.pezones.estado",
        "label": "Pezones · Estado",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Relajado",
            "label": "Relajado"
          },
          {
            "value": "Firme",
            "label": "Firme"
          },
          {
            "value": "Variable según contexto",
            "label": "Variable según contexto"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.busto.pezones.asimetria",
        "label": "Pezones · Asimetría",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "No",
            "label": "No"
          },
          {
            "value": "Sí",
            "label": "Sí"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.caderas.medida",
        "label": "Caderas · Medida de caderas (cm)",
        "type": "number",
        "multiline": false,
        "advanced": true
      },
      {
        "key": "physical.caderas.forma",
        "label": "Caderas · Forma de caderas",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Caderas en forma de corazón",
            "label": "Caderas en forma de corazón"
          },
          {
            "value": "Caderas redondas",
            "label": "Caderas redondas"
          },
          {
            "value": "Caderas anchas",
            "label": "Caderas anchas"
          },
          {
            "value": "Caderas Medias / equilibradas",
            "label": "Caderas Medias / equilibradas"
          },
          {
            "value": "Caderas cuadradas",
            "label": "Caderas cuadradas"
          },
          {
            "value": "Caderas estrechas / Rectas",
            "label": "Caderas estrechas / Rectas"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.caderas.textura",
        "label": "Caderas · Textura / tonicidad de las caderas",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Firme y tonificada",
            "label": "Firme y tonificada"
          },
          {
            "value": "Dura / musculosa",
            "label": "Dura / musculosa"
          },
          {
            "value": "Mixta",
            "label": "Mixta"
          },
          {
            "value": "Suave y blanda",
            "label": "Suave y blanda"
          },
          {
            "value": "Flácida / con poca firmeza",
            "label": "Flácida / con poca firmeza"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.trasero.forma",
        "label": "Trasero · Forma del trasero",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "En forma de corazón (A)",
            "label": "En forma de corazón (A)"
          },
          {
            "value": "Redondo (tipo burbuja / O)",
            "label": "Redondo (tipo burbuja / O)"
          },
          {
            "value": "En forma de pera",
            "label": "En forma de pera"
          },
          {
            "value": "Cuadrado (H)",
            "label": "Cuadrado (H)"
          },
          {
            "value": "En forma de V (triángulo invertido)",
            "label": "En forma de V (triángulo invertido)"
          },
          {
            "value": "Plano",
            "label": "Plano"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.trasero.proyeccion",
        "label": "Trasero · Proyección del trasero",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Con proyección alta",
            "label": "Con proyección alta"
          },
          {
            "value": "Con proyección media",
            "label": "Con proyección media"
          },
          {
            "value": "Con proyección baja",
            "label": "Con proyección baja"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.trasero.tamano",
        "label": "Trasero · Volumen o Tamaño del trasero",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Muy grande",
            "label": "Muy grande"
          },
          {
            "value": "Grande",
            "label": "Grande"
          },
          {
            "value": "Mediano",
            "label": "Mediano"
          },
          {
            "value": "Pequeño",
            "label": "Pequeño"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.trasero.firmeza",
        "label": "Trasero · Firmeza del trasero",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Muy firme / musculoso",
            "label": "Muy firme / musculoso"
          },
          {
            "value": "Firme",
            "label": "Firme"
          },
          {
            "value": "Semifirme",
            "label": "Semifirme"
          },
          {
            "value": "Blando",
            "label": "Blando"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_mayores.forma",
        "label": "Labios mayores · Forma / apariencia",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Redondeados / carnosos",
            "label": "Redondeados / carnosos"
          },
          {
            "value": "Planos / finos",
            "label": "Planos / finos"
          },
          {
            "value": "Alargados",
            "label": "Alargados"
          },
          {
            "value": "Gruesos",
            "label": "Gruesos"
          },
          {
            "value": "Con pliegues",
            "label": "Con pliegues"
          },
          {
            "value": "Asimétricos",
            "label": "Asimétricos"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_mayores.tamano",
        "label": "Labios mayores · Tamaño",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "6 cm (Pequeño)",
            "label": "6 cm (Pequeño)"
          },
          {
            "value": "7 cm (Pequeño)",
            "label": "7 cm (Pequeño)"
          },
          {
            "value": "8 cm (Pequeño-Medio)",
            "label": "8 cm (Pequeño-Medio)"
          },
          {
            "value": "9 cm (Común)",
            "label": "9 cm (Común)"
          },
          {
            "value": "10 cm (Común)",
            "label": "10 cm (Común)"
          },
          {
            "value": "11 cm (Medio-Grande)",
            "label": "11 cm (Medio-Grande)"
          },
          {
            "value": "12 cm (Grande)",
            "label": "12 cm (Grande)"
          },
          {
            "value": "13 cm (Grande)",
            "label": "13 cm (Grande)"
          },
          {
            "value": "14 cm (Muy grande)",
            "label": "14 cm (Muy grande)"
          },
          {
            "value": "15 cm (Muy grande)",
            "label": "15 cm (Muy grande)"
          },
          {
            "value": "16 cm (Muy grande)",
            "label": "16 cm (Muy grande)"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_mayores.simetria",
        "label": "Labios mayores · Simetría",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Simétricos",
            "label": "Simétricos"
          },
          {
            "value": "Ligeramente asimétricos",
            "label": "Ligeramente asimétricos"
          },
          {
            "value": "Claramente asimétricos",
            "label": "Claramente asimétricos"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_mayores.color",
        "label": "Labios mayores · Color / tono",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Rosa claro",
            "label": "Rosa claro"
          },
          {
            "value": "Rosa",
            "label": "Rosa"
          },
          {
            "value": "Rosado-marrón",
            "label": "Rosado-marrón"
          },
          {
            "value": "Marrón claro",
            "label": "Marrón claro"
          },
          {
            "value": "Marrón",
            "label": "Marrón"
          },
          {
            "value": "Marrón oscuro",
            "label": "Marrón oscuro"
          },
          {
            "value": "Casi negro",
            "label": "Casi negro"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_menores.forma",
        "label": "Labios menores · Forma / apariencia",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Lisos",
            "label": "Lisos"
          },
          {
            "value": "Con pliegues / rizados",
            "label": "Con pliegues / rizados"
          },
          {
            "value": "Alargados",
            "label": "Alargados"
          },
          {
            "value": "Cortos y ocultos",
            "label": "Cortos y ocultos"
          },
          {
            "value": "Que sobresalen de los mayores",
            "label": "Que sobresalen de los mayores"
          },
          {
            "value": "En forma de “hoja”",
            "label": "En forma de “hoja”"
          },
          {
            "value": "Asimétricos",
            "label": "Asimétricos"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_menores.tamano",
        "label": "Labios menores · Tamaño",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "0,5 cm (Muy pequeño)",
            "label": "0,5 cm (Muy pequeño)"
          },
          {
            "value": "1,0 cm (Pequeño)",
            "label": "1,0 cm (Pequeño)"
          },
          {
            "value": "1,5 cm (Pequeño-Medio)",
            "label": "1,5 cm (Pequeño-Medio)"
          },
          {
            "value": "2,0 cm (Común)",
            "label": "2,0 cm (Común)"
          },
          {
            "value": "2,5 cm (Común)",
            "label": "2,5 cm (Común)"
          },
          {
            "value": "3,0 cm (Medio-Grande)",
            "label": "3,0 cm (Medio-Grande)"
          },
          {
            "value": "3,5 cm (Grande)",
            "label": "3,5 cm (Grande)"
          },
          {
            "value": "4,0 cm (Grande)",
            "label": "4,0 cm (Grande)"
          },
          {
            "value": "4,5 cm (Muy grande)",
            "label": "4,5 cm (Muy grande)"
          },
          {
            "value": "5,0 cm (Muy grande)",
            "label": "5,0 cm (Muy grande)"
          },
          {
            "value": "5,5 cm (Muy grande)",
            "label": "5,5 cm (Muy grande)"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_menores.prominencia",
        "label": "Labios menores · Prominencia",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Ocultos (no sobresalen de los mayores)",
            "label": "Ocultos (no sobresalen de los mayores)"
          },
          {
            "value": "Parcialmente visibles",
            "label": "Parcialmente visibles"
          },
          {
            "value": "Claramente sobresalientes",
            "label": "Claramente sobresalientes"
          },
          {
            "value": "Muy sobresalientes",
            "label": "Muy sobresalientes"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_menores.simetria",
        "label": "Labios menores · Simetría",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Simétricos",
            "label": "Simétricos"
          },
          {
            "value": "Ligeramente asimétricos",
            "label": "Ligeramente asimétricos"
          },
          {
            "value": "Claramente asimétricos",
            "label": "Claramente asimétricos"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.labios_menores.color",
        "label": "Labios menores · Color / tono",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Rosa claro",
            "label": "Rosa claro"
          },
          {
            "value": "Rosa",
            "label": "Rosa"
          },
          {
            "value": "Rosado intenso",
            "label": "Rosado intenso"
          },
          {
            "value": "Rosado-marrón",
            "label": "Rosado-marrón"
          },
          {
            "value": "Marrón claro",
            "label": "Marrón claro"
          },
          {
            "value": "Marrón",
            "label": "Marrón"
          },
          {
            "value": "Marrón oscuro / violáceo",
            "label": "Marrón oscuro / violáceo"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.clitoris.tamano",
        "label": "Clítoris · Tamaño",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Pequeño",
            "label": "Pequeño"
          },
          {
            "value": "Mediano",
            "label": "Mediano"
          },
          {
            "value": "Grande",
            "label": "Grande"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.clitoris.visibilidad",
        "label": "Clítoris · Visibilidad",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Poco visible",
            "label": "Poco visible"
          },
          {
            "value": "Parcialmente visible",
            "label": "Parcialmente visible"
          },
          {
            "value": "Visible",
            "label": "Visible"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.clitoris.capuchon",
        "label": "Clítoris · Cobertura del capuchón",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Completa",
            "label": "Completa"
          },
          {
            "value": "Parcial",
            "label": "Parcial"
          },
          {
            "value": "Mínima",
            "label": "Mínima"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.clitoris.observaciones",
        "label": "Clítoris · Observaciones",
        "type": "text",
        "multiline": true,
        "advanced": true
      },
      {
        "key": "physical.anatomia.vello.presencia",
        "label": "Vello púbico · Presencia",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "No",
            "label": "No"
          },
          {
            "value": "Sí",
            "label": "Sí"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.vello.estilo",
        "label": "Vello púbico · Estilo / distribución",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Depilación completa",
            "label": "Depilación completa"
          },
          {
            "value": "Recortado",
            "label": "Recortado"
          },
          {
            "value": "Natural",
            "label": "Natural"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "Sin especificar",
        "advanced": true
      },
      {
        "key": "physical.anatomia.vello.color",
        "label": "Vello púbico · Color",
        "type": "text",
        "multiline": false,
        "advanced": true
      },
      {
        "key": "physical.anatomia.vello.observaciones",
        "label": "Vello púbico · Observaciones",
        "type": "text",
        "multiline": true,
        "advanced": true
      },
      {
        "key": "physical.cabello.color",
        "label": "Cabello · color",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "physical.cabello.longitud",
        "label": "Cabello · longitud",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Muy corto",
            "label": "Muy corto"
          },
          {
            "value": "Corto",
            "label": "Corto"
          },
          {
            "value": "Medio",
            "label": "Medio"
          },
          {
            "value": "Largo",
            "label": "Largo"
          },
          {
            "value": "Muy largo",
            "label": "Muy largo"
          }
        ],
        "default": "Sin especificar",
        "advanced": false
      },
      {
        "key": "physical.cabello.corte",
        "label": "Corte / estilo",
        "type": "select",
        "multiline": false,
        "options": [],
        "default": "",
        "advanced": false
      },
      {
        "key": "physical.cabello.flequillo",
        "label": "Fleco",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Cortina",
            "label": "Cortina"
          },
          {
            "value": "Desfilado",
            "label": "Desfilado"
          },
          {
            "value": "Despuntado",
            "label": "Despuntado"
          },
          {
            "value": "Ladeado",
            "label": "Ladeado"
          },
          {
            "value": "Corto",
            "label": "Corto"
          },
          {
            "value": "Largo",
            "label": "Largo"
          },
          {
            "value": "Rizado",
            "label": "Rizado"
          },
          {
            "value": "Wispy",
            "label": "Wispy"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "physical.ojos.color",
        "label": "Ojos · color",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "physical.ojos.forma",
        "label": "Ojos · forma",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Almendrados",
            "label": "Almendrados"
          },
          {
            "value": "Caídos",
            "label": "Caídos"
          },
          {
            "value": "Redondos",
            "label": "Redondos"
          },
          {
            "value": "Hundidos",
            "label": "Hundidos"
          },
          {
            "value": "Encapotados",
            "label": "Encapotados"
          },
          {
            "value": "Prominentes",
            "label": "Prominentes"
          },
          {
            "value": "Separados",
            "label": "Separados"
          },
          {
            "value": "Juntos",
            "label": "Juntos"
          },
          {
            "value": "Asiáticos",
            "label": "Asiáticos"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "physical.rostro.forma",
        "label": "Forma del rostro",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Redondo",
            "label": "Redondo"
          },
          {
            "value": "Ovalada",
            "label": "Ovalada"
          },
          {
            "value": "Diamante",
            "label": "Diamante"
          },
          {
            "value": "Cuadrado",
            "label": "Cuadrado"
          },
          {
            "value": "Triangular A",
            "label": "Triangular A"
          },
          {
            "value": "Triangular V",
            "label": "Triangular V"
          },
          {
            "value": "Rectangular",
            "label": "Rectangular"
          },
          {
            "value": "Alargado",
            "label": "Alargado"
          },
          {
            "value": "Corazón",
            "label": "Corazón"
          }
        ],
        "default": "",
        "advanced": true
      },
      {
        "key": "physical.rostro.detalles",
        "label": "Detalles faciales",
        "type": "text",
        "multiline": true,
        "advanced": true
      }
    ],
    "advanced": false
  },
  {
    "id": "vestimenta-inicial",
    "title": "👚 3 · Vestimenta inicial",
    "fields": [
      {
        "key": "initial_outfit.parte_superior",
        "label": "Parte superior",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.parte_inferior",
        "label": "Parte inferior",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.calzado",
        "label": "Calzado",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.brasier.tipo",
        "label": "Brasier · Tipo / modelo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Balconette",
            "label": "Balconette"
          },
          {
            "value": "Demi-cup",
            "label": "Demi-cup"
          },
          {
            "value": "Plunge",
            "label": "Plunge"
          },
          {
            "value": "Push-up",
            "label": "Push-up"
          },
          {
            "value": "Quarter-cup",
            "label": "Quarter-cup"
          },
          {
            "value": "Longline",
            "label": "Longline"
          },
          {
            "value": "Lace",
            "label": "Lace"
          },
          {
            "value": "Sheer",
            "label": "Sheer"
          },
          {
            "value": "Strappy",
            "label": "Strappy"
          },
          {
            "value": "Bralette",
            "label": "Bralette"
          },
          {
            "value": "Bustier",
            "label": "Bustier"
          },
          {
            "value": "Underwire",
            "label": "Underwire"
          },
          {
            "value": "Pezoneras",
            "label": "Pezoneras"
          },
          {
            "value": "Triangle",
            "label": "Triangle"
          },
          {
            "value": "Unlined",
            "label": "Unlined"
          },
          {
            "value": "Deportivo",
            "label": "Deportivo"
          },
          {
            "value": "Sin brasiere",
            "label": "Sin brasiere"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.brasier.estilo",
        "label": "Brasier · Estilo / acabado",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Liso",
            "label": "Liso"
          },
          {
            "value": "Encaje",
            "label": "Encaje"
          },
          {
            "value": "Transparente",
            "label": "Transparente"
          },
          {
            "value": "Malla",
            "label": "Malla"
          },
          {
            "value": "Algodón",
            "label": "Algodón"
          },
          {
            "value": "Bordado",
            "label": "Bordado"
          },
          {
            "value": "Estampado",
            "label": "Estampado"
          },
          {
            "value": "Acanalado",
            "label": "Acanalado"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.brasier.cierre",
        "label": "Brasier · Tipo de cierre",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Broche trasero",
            "label": "Broche trasero"
          },
          {
            "value": "Broche frontal",
            "label": "Broche frontal"
          },
          {
            "value": "Cierre magnético",
            "label": "Cierre magnético"
          },
          {
            "value": "Sin broche",
            "label": "Sin broche"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.brasier.color",
        "label": "Brasier · Color",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.panties.tipo",
        "label": "Panties · Tipo / modelo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Tanga",
            "label": "Tanga"
          },
          {
            "value": "G-string",
            "label": "G-string"
          },
          {
            "value": "V-string",
            "label": "V-string"
          },
          {
            "value": "Brasileña",
            "label": "Brasileña"
          },
          {
            "value": "Cheeky",
            "label": "Cheeky"
          },
          {
            "value": "Lace",
            "label": "Lace"
          },
          {
            "value": "Sheer",
            "label": "Sheer"
          },
          {
            "value": "High-leg",
            "label": "High-leg"
          },
          {
            "value": "Low-rise",
            "label": "Low-rise"
          },
          {
            "value": "Strappy",
            "label": "Strappy"
          },
          {
            "value": "Cage",
            "label": "Cage"
          },
          {
            "value": "High-waisted",
            "label": "High-waisted"
          },
          {
            "value": "French-cut",
            "label": "French-cut"
          },
          {
            "value": "Tie-side",
            "label": "Tie-side"
          },
          {
            "value": "Crotchless",
            "label": "Crotchless"
          },
          {
            "value": "Deportivo",
            "label": "Deportivo"
          },
          {
            "value": "Sin panties",
            "label": "Sin panties"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.panties.estilo",
        "label": "Panties · Estilo / acabado",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Liso",
            "label": "Liso"
          },
          {
            "value": "Encaje",
            "label": "Encaje"
          },
          {
            "value": "Transparente",
            "label": "Transparente"
          },
          {
            "value": "Malla",
            "label": "Malla"
          },
          {
            "value": "Algodón",
            "label": "Algodón"
          },
          {
            "value": "Bordado",
            "label": "Bordado"
          },
          {
            "value": "Estampado",
            "label": "Estampado"
          },
          {
            "value": "Acanalado",
            "label": "Acanalado"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.panties.sujecion",
        "label": "Panties · Tipo de sujeción",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Elástica",
            "label": "Elástica"
          },
          {
            "value": "Lazos laterales",
            "label": "Lazos laterales"
          },
          {
            "value": "Broches laterales",
            "label": "Broches laterales"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_interior.panties.color",
        "label": "Panties · Color",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.brasier_bikini.tipo",
        "label": "Brasier de bikini · Tipo / modelo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Triangle",
            "label": "Triangle"
          },
          {
            "value": "Bandeau",
            "label": "Bandeau"
          },
          {
            "value": "Halter",
            "label": "Halter"
          },
          {
            "value": "Balconette",
            "label": "Balconette"
          },
          {
            "value": "Underwire",
            "label": "Underwire"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.brasier_bikini.estilo",
        "label": "Brasier de bikini · Estilo / acabado",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Liso",
            "label": "Liso"
          },
          {
            "value": "Estampado",
            "label": "Estampado"
          },
          {
            "value": "Floral",
            "label": "Floral"
          },
          {
            "value": "Tropical",
            "label": "Tropical"
          },
          {
            "value": "Rayado",
            "label": "Rayado"
          },
          {
            "value": "Fruncido",
            "label": "Fruncido"
          },
          {
            "value": "Tejido",
            "label": "Tejido"
          },
          {
            "value": "Crochet",
            "label": "Crochet"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.brasier_bikini.sujecion",
        "label": "Brasier de bikini · Tipo de sujeción",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Broche trasero",
            "label": "Broche trasero"
          },
          {
            "value": "Broche frontal",
            "label": "Broche frontal"
          },
          {
            "value": "Lazo trasero",
            "label": "Lazo trasero"
          },
          {
            "value": "Halter con lazo al cuello y lazo trasero",
            "label": "Halter con lazo al cuello y lazo trasero"
          },
          {
            "value": "Lazo frontal",
            "label": "Lazo frontal"
          },
          {
            "value": "Sin cierre (tipo top)",
            "label": "Sin cierre (tipo top)"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.brasier_bikini.color",
        "label": "Brasier de bikini · Color",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.panty_bikini.tipo",
        "label": "Panty de bikini · Modelo / tipo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Bikini clásico",
            "label": "Bikini clásico"
          },
          {
            "value": "Tanga",
            "label": "Tanga"
          },
          {
            "value": "Brasileña",
            "label": "Brasileña"
          },
          {
            "value": "High-waisted",
            "label": "High-waisted"
          },
          {
            "value": "Tie-side",
            "label": "Tie-side"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.panty_bikini.estilo",
        "label": "Panty de bikini · Estilo / acabado",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Liso",
            "label": "Liso"
          },
          {
            "value": "Estampado",
            "label": "Estampado"
          },
          {
            "value": "Floral",
            "label": "Floral"
          },
          {
            "value": "Tropical",
            "label": "Tropical"
          },
          {
            "value": "Rayado",
            "label": "Rayado"
          },
          {
            "value": "Fruncido",
            "label": "Fruncido"
          },
          {
            "value": "Tejido",
            "label": "Tejido"
          },
          {
            "value": "Crochet",
            "label": "Crochet"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.panty_bikini.sujecion",
        "label": "Panty de bikini · Tipo de sujeción",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Elástica",
            "label": "Elástica"
          },
          {
            "value": "Lazos laterales",
            "label": "Lazos laterales"
          },
          {
            "value": "Broches laterales",
            "label": "Broches laterales"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "initial_outfit.ropa_playa.panty_bikini.color",
        "label": "Panty de bikini · Color",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.accesorios",
        "label": "Accesorios",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.prenda_exterior",
        "label": "Prenda exterior",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "initial_outfit.descripcion",
        "label": "Descripción adicional",
        "type": "text",
        "multiline": true,
        "advanced": false
      }
    ],
    "advanced": false
  },
  {
    "id": "personalidad",
    "title": "🧠 4 · Personalidad",
    "fields": [
      {
        "key": "personality.descripcion",
        "label": "Descripción de personalidad",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "personality.gustos",
        "label": "Gustos",
        "type": "text",
        "multiline": true,
        "advanced": true
      },
      {
        "key": "personality.disgustos",
        "label": "Disgustos",
        "type": "text",
        "multiline": true,
        "advanced": true
      },
      {
        "key": "personality.miedos",
        "label": "Miedos",
        "type": "text",
        "multiline": true,
        "advanced": true
      }
    ],
    "advanced": false
  },
  {
    "id": "contexto",
    "title": "🌎 5 · Historia y contexto",
    "fields": [
      {
        "key": "history.biografia",
        "label": "Historia / antecedentes",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "context.situacion",
        "label": "Situación actual",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "context.motivaciones_objetivos",
        "label": "Motivaciones / objetivos",
        "type": "text",
        "multiline": true,
        "advanced": false
      }
    ],
    "advanced": false
  },
  {
    "id": "sexualidad",
    "title": "🔥 6 · Sexualidad e intimidad",
    "fields": [
      {
        "key": "sexuality.first_experience.with.type",
        "label": "Fue con",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "user",
            "label": "{{user}}"
          },
          {
            "value": "char",
            "label": "Otro {{char}}"
          },
          {
            "value": "unregistered",
            "label": "Personaje no registrado"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "sexuality.first_experience.with.user_id",
        "label": "Perfil {{user}} vinculado",
        "type": "persona",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Seleccionar perfil {{user}}…"
          }
        ],
        "default": "",
        "target": "user",
        "advanced": false
      },
      {
        "key": "sexuality.first_experience.with.char_id",
        "label": "{{char}} vinculado",
        "type": "character",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Seleccionar otro {{char}}…"
          }
        ],
        "default": "",
        "target": "char",
        "advanced": false
      },
      {
        "key": "sexuality.first_experience.with.unregistered_name",
        "label": "Nombre del personaje",
        "type": "text",
        "multiline": false,
        "target": "unregistered",
        "advanced": false
      },
      {
        "key": "sexuality.first_experience.backstory",
        "label": "Backstory de la primera vez",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "sexuality.experience.level",
        "label": "Nivel de experiencia sexual",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Sin experiencia",
            "label": "Sin experiencia"
          },
          {
            "value": "Muy poca",
            "label": "Muy poca"
          },
          {
            "value": "Poca",
            "label": "Poca"
          },
          {
            "value": "Moderada",
            "label": "Moderada"
          },
          {
            "value": "Amplia",
            "label": "Amplia"
          },
          {
            "value": "Muy amplia",
            "label": "Muy amplia"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "sexuality.libido.level",
        "label": "Deseo / libido",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Muy bajo",
            "label": "Muy bajo"
          },
          {
            "value": "Bajo",
            "label": "Bajo"
          },
          {
            "value": "Medio",
            "label": "Medio"
          },
          {
            "value": "Alto",
            "label": "Alto"
          },
          {
            "value": "Muy alto",
            "label": "Muy alto"
          }
        ],
        "default": "",
        "advanced": false
      },
      {
        "key": "sexuality.erogenous_zones",
        "label": "Zonas erógenas",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "sexuality.self_pleasure",
        "label": "Autoplacer",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "sexuality.preferences_interests",
        "label": "Preferencias e intereses sexuales",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "sexuality.limits",
        "label": "Límites sexuales",
        "type": "text",
        "multiline": true,
        "advanced": false
      }
    ],
    "advanced": false
  },
  {
    "id": "reluser",
    "title": "❤️ 7 · Relación con {{user}}",
    "fields": [
      {
        "key": "relationship_scenario.primary_type",
        "label": "Escenario de relación",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "none",
            "label": "Sin escenario especial"
          },
          {
            "value": "romance",
            "label": "Romance"
          },
          {
            "value": "friends_romance",
            "label": "Amistad → Romance"
          },
          {
            "value": "enemies_romance",
            "label": "Enemigos → Romance"
          },
          {
            "value": "rivals_romance",
            "label": "Rivales → Romance"
          },
          {
            "value": "unrequited",
            "label": "Amor no correspondido"
          },
          {
            "value": "secret_love",
            "label": "Amor secreto"
          },
          {
            "value": "secret_relationship",
            "label": "Relación secreta"
          },
          {
            "value": "ex_reunion",
            "label": "Expareja / Reencuentro"
          },
          {
            "value": "stable",
            "label": "Matrimonio / Pareja estable"
          },
          {
            "value": "arranged",
            "label": "Matrimonio arreglado"
          },
          {
            "value": "triangle",
            "label": "Triángulo amoroso"
          },
          {
            "value": "romantic_rivalry",
            "label": "Rivalidad romántica"
          },
          {
            "value": "multiple_suitors",
            "label": "Múltiples pretendientes"
          },
          {
            "value": "open",
            "label": "Relación abierta"
          },
          {
            "value": "poly",
            "label": "Poliamor"
          },
          {
            "value": "ntr",
            "label": "NTR"
          },
          {
            "value": "netorare",
            "label": "Netorare"
          },
          {
            "value": "netori",
            "label": "Netori"
          },
          {
            "value": "netorase",
            "label": "Netorase"
          },
          {
            "value": "infidelity",
            "label": "Infidelidad"
          },
          {
            "value": "secret_affair",
            "label": "Aventura secreta"
          },
          {
            "value": "double_relationship",
            "label": "Doble relación"
          },
          {
            "value": "jealousy",
            "label": "Celos"
          },
          {
            "value": "crisis",
            "label": "Crisis de pareja"
          },
          {
            "value": "breakup",
            "label": "Ruptura"
          },
          {
            "value": "reconciliation",
            "label": "Reconciliación"
          },
          {
            "value": "custom",
            "label": "Personalizado…"
          }
        ],
        "default": "none",
        "advanced": false
      },
      {
        "key": "relationship_scenario.config.user_role",
        "label": "Rol de {{user}}",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Tercero / Netori",
            "label": "Tercero / Netori"
          },
          {
            "value": "Pareja afectada",
            "label": "Pareja afectada"
          },
          {
            "value": "Pareja que consiente",
            "label": "Pareja que consiente"
          },
          {
            "value": "Observador",
            "label": "Observador"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "Sin especificar",
        "scenario": [
          "netori",
          "ntr",
          "netorare",
          "netorase",
          "infidelity",
          "secret_affair",
          "double_relationship"
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.config.initial_partner",
        "label": "Pareja inicial de {{char}}",
        "type": "character",
        "multiline": false,
        "options": [
          {
            "value": "Sin seleccionar",
            "label": "Sin seleccionar"
          },
          {
            "value": "Seleccionar {{char}} existente…",
            "label": "Seleccionar {{char}} existente…"
          }
        ],
        "default": "Sin seleccionar",
        "scenario": [
          "netori",
          "ntr",
          "netorare",
          "netorase",
          "infidelity",
          "secret_affair",
          "double_relationship"
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.config.partner_awareness",
        "label": "Conocimiento de la pareja",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "No sabe",
            "label": "No sabe"
          },
          {
            "value": "Sospecha",
            "label": "Sospecha"
          },
          {
            "value": "Sabe",
            "label": "Sabe"
          },
          {
            "value": "Consiente",
            "label": "Consiente"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "No sabe",
        "scenario": [
          "netori",
          "ntr",
          "netorare",
          "netorase",
          "infidelity",
          "secret_affair",
          "double_relationship"
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.config.evolution",
        "label": "Evolución",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Dinámica",
            "label": "Dinámica"
          },
          {
            "value": "Fija",
            "label": "Fija"
          },
          {
            "value": "Guiada por reglas",
            "label": "Guiada por reglas"
          }
        ],
        "default": "Dinámica",
        "scenario": [
          "netori",
          "ntr",
          "netorare",
          "netorase",
          "infidelity",
          "secret_affair",
          "double_relationship"
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.details",
        "label": "Detalles del escenario",
        "type": "text",
        "multiline": true,
        "scenario": [
          "netori",
          "ntr",
          "netorare",
          "netorase",
          "infidelity",
          "secret_affair",
          "double_relationship"
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.custom_name",
        "label": "Nombre del escenario personalizado",
        "type": "text",
        "multiline": false,
        "scenario": [
          "custom"
        ],
        "advanced": false
      },
      {
        "key": "relation_user.tipo",
        "label": "Tipo de relación",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Desconocidos",
            "label": "Desconocidos"
          },
          {
            "value": "Conocidos",
            "label": "Conocidos"
          },
          {
            "value": "Amigos",
            "label": "Amigos"
          },
          {
            "value": "Mejores amigos",
            "label": "Mejores amigos"
          },
          {
            "value": "Compañeros",
            "label": "Compañeros"
          },
          {
            "value": "Pareja",
            "label": "Pareja"
          },
          {
            "value": "Expareja",
            "label": "Expareja"
          },
          {
            "value": "Familia",
            "label": "Familia"
          },
          {
            "value": "Rivales",
            "label": "Rivales"
          },
          {
            "value": "Enemigos",
            "label": "Enemigos"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "Sin especificar",
        "advanced": false
      },
      {
        "key": "relation_user.actitud",
        "label": "Actitud",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "relation_user.pensamientos",
        "label": "Pensamientos",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "relation_user.sentimientos",
        "label": "Sentimientos",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "relation_user.deseos",
        "label": "Deseos",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "relation_user.intenciones",
        "label": "Intenciones",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "relationship_scenario.multi.interest_a",
        "label": "Interés A",
        "type": "participant",
        "scenario": [
          "triangle",
          "romantic_rivalry",
          "multiple_suitors"
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.multi.interest_b",
        "label": "Interés B",
        "type": "participant",
        "scenario": [
          "triangle",
          "romantic_rivalry",
          "multiple_suitors"
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.multi.rivalry",
        "label": "¿Existe rivalidad?",
        "type": "select",
        "scenario": [
          "triangle",
          "romantic_rivalry",
          "multiple_suitors"
        ],
        "options": [
          {
            "value": "Sí",
            "label": "Sí"
          },
          {
            "value": "No",
            "label": "No"
          },
          {
            "value": "Depende",
            "label": "Depende"
          }
        ],
        "advanced": false
      },
      {
        "key": "relationship_scenario.multi.awareness",
        "label": "¿Conocen la situación?",
        "type": "select",
        "scenario": [
          "triangle",
          "romantic_rivalry",
          "multiple_suitors"
        ],
        "options": [
          {
            "value": "No",
            "label": "No"
          },
          {
            "value": "Parcialmente",
            "label": "Parcialmente"
          },
          {
            "value": "Sí",
            "label": "Sí"
          }
        ],
        "advanced": false
      }
    ],
    "advanced": false
  },
  {
    "id": "relchars",
    "title": "🔗 8 · Relaciones con otros personajes",
    "fields": [],
    "advanced": true
  },
  {
    "id": "mensajes",
    "title": "💬 9 · Mensajes",
    "fields": [
      {
        "key": "messages.initial",
        "label": "Mensaje inicial",
        "type": "text",
        "multiline": true,
        "advanced": false
      }
    ],
    "advanced": false
  },
  {
    "id": "expresion",
    "title": "🗣️ 10 · Expresión y comunicación",
    "fields": [
      {
        "key": "expression.language.primary",
        "label": "Idioma principal",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Español",
            "label": "Español"
          },
          {
            "value": "Inglés",
            "label": "Inglés"
          },
          {
            "value": "Japonés",
            "label": "Japonés"
          },
          {
            "value": "Italiano",
            "label": "Italiano"
          },
          {
            "value": "Ruso",
            "label": "Ruso"
          },
          {
            "value": "Francés",
            "label": "Francés"
          },
          {
            "value": "Alemán",
            "label": "Alemán"
          },
          {
            "value": "Coreano",
            "label": "Coreano"
          },
          {
            "value": "Chino",
            "label": "Chino"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "Español",
        "advanced": false
      },
      {
        "key": "expression.language.accent",
        "label": "Acento",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "expression.language.use",
        "label": "Uso",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "expression.language.switch_rules",
        "label": "Reglas de cambio de idioma",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "expression.voice.tone",
        "label": "Tono",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Suave",
            "label": "Suave"
          },
          {
            "value": "Cálido",
            "label": "Cálido"
          },
          {
            "value": "Enérgico",
            "label": "Enérgico"
          },
          {
            "value": "Serio",
            "label": "Serio"
          },
          {
            "value": "Coqueto",
            "label": "Coqueto"
          },
          {
            "value": "Frío",
            "label": "Frío"
          },
          {
            "value": "Personalizado…",
            "label": "Personalizado…"
          }
        ],
        "default": "Sin especificar",
        "advanced": false
      },
      {
        "key": "expression.voice.speed",
        "label": "Velocidad",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Sin especificar",
            "label": "Sin especificar"
          },
          {
            "value": "Lenta",
            "label": "Lenta"
          },
          {
            "value": "Normal",
            "label": "Normal"
          },
          {
            "value": "Rápida",
            "label": "Rápida"
          },
          {
            "value": "Variable",
            "label": "Variable"
          }
        ],
        "default": "Sin especificar",
        "advanced": false
      },
      {
        "key": "expression.speech.style",
        "label": "Estilo",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "expression.speech.vocabulary",
        "label": "Vocabulario",
        "type": "text",
        "multiline": false,
        "advanced": false
      },
      {
        "key": "expression.speech.fillers",
        "label": "Muletillas",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "expression.speech.expressions",
        "label": "Expresiones habituales",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "expression.speech.address_user",
        "label": "Forma de dirigirse a {{user}}",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "expression.behavior.gestures",
        "label": "Gestos habituales",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "expression.behavior.body_language",
        "label": "Lenguaje corporal",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "expression.behavior.posture",
        "label": "Postura habitual",
        "type": "text",
        "multiline": true,
        "advanced": false
      },
      {
        "key": "expression.behavior.quirks",
        "label": "Manías / peculiaridades",
        "type": "text",
        "multiline": true,
        "advanced": false
      }
    ],
    "advanced": true
  },
  {
    "id": "bot",
    "title": "⚙️ 11 · Respuestas del bot",
    "fields": [
      {
        "key": "bot.length",
        "label": "Longitud",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Corta",
            "label": "Corta"
          },
          {
            "value": "Media",
            "label": "Media"
          },
          {
            "value": "Larga",
            "label": "Larga"
          },
          {
            "value": "Personalizada",
            "label": "Personalizada"
          }
        ],
        "default": "Media",
        "advanced": false
      },
      {
        "key": "bot.detail",
        "label": "Nivel de detalle",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Bajo",
            "label": "Bajo"
          },
          {
            "value": "Medio",
            "label": "Medio"
          },
          {
            "value": "Alto",
            "label": "Alto"
          }
        ],
        "default": "Medio",
        "advanced": false
      },
      {
        "key": "bot.pacing",
        "label": "Ritmo narrativo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Lento",
            "label": "Lento"
          },
          {
            "value": "Equilibrado",
            "label": "Equilibrado"
          },
          {
            "value": "Rápido",
            "label": "Rápido"
          },
          {
            "value": "Variable",
            "label": "Variable"
          }
        ],
        "default": "Equilibrado",
        "advanced": false
      },
      {
        "key": "bot.narrative_style",
        "label": "Estilo narrativo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Primera persona",
            "label": "Primera persona"
          },
          {
            "value": "Tercera persona",
            "label": "Tercera persona"
          },
          {
            "value": "Personalizado",
            "label": "Personalizado"
          }
        ],
        "default": "Primera persona",
        "advanced": false
      },
      {
        "key": "bot.format",
        "label": "Formato narrativo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "Diálogo + acciones",
            "label": "Diálogo + acciones"
          },
          {
            "value": "Narrativo",
            "label": "Narrativo"
          },
          {
            "value": "Chat directo",
            "label": "Chat directo"
          },
          {
            "value": "Personalizado",
            "label": "Personalizado"
          }
        ],
        "default": "Diálogo + acciones",
        "advanced": false
      },
      {
        "key": "bot.additional",
        "label": "Instrucciones adicionales",
        "type": "text",
        "multiline": true,
        "advanced": false
      }
    ],
    "advanced": true
  }
]''')
            as List)
        .cast<Map<String, dynamic>>();
