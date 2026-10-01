// Neutral field catalogue extracted from the supplied male UI prototype.
import 'dart:convert';

final List<Map<String, dynamic>> maleSections =
    (jsonDecode(r'''[
  {
    "id": "perfil",
    "title": "👤 1 · Perfil",
    "advanced": false,
    "fields": [
      {
        "key": "identity.nombre",
        "label": "Nombre",
        "type": "text",
        "multiline": false
      },
      {
        "key": "identity.apellido",
        "label": "Apellido",
        "type": "text",
        "multiline": false
      },
      {
        "key": "identity.apodo",
        "label": "Apodo",
        "type": "text",
        "multiline": false
      },
      {
        "key": "identidad.edad",
        "label": "Edad",
        "type": "number",
        "multiline": false
      },
      {
        "key": "identidad.genero",
        "label": "Género",
        "type": "select",
        "multiline": false,
        "readonly": true,
        "options": [
          {
            "value": "hombre",
            "label": "Hombre · fijo en esta plantilla"
          }
        ],
        "default": "hombre"
      },
      {
        "key": "identidad.orientacion",
        "label": "Orientación sexual",
        "type": "select",
        "multiline": false,
        "readonly": true,
        "options": [
          {
            "value": "heterosexual",
            "label": "Heterosexual · fijo en esta plantilla"
          }
        ],
        "default": "heterosexual"
      },
      {
        "key": "identidad.nacionalidad",
        "label": "Nacionalidad",
        "type": "text",
        "multiline": false
      },
      {
        "key": "identidad.etnia",
        "label": "Etnia",
        "type": "text",
        "multiline": false
      }
    ]
  },
  {
    "id": "apariencia",
    "title": "🧍 2 · Apariencia",
    "advanced": false,
    "fields": [
      {
        "key": "apariencia.tono_piel",
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
        "default": ""
      },
      {
        "key": "apariencia.complexion",
        "label": "Complexión",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Delgado",
            "label": "Delgado"
          },
          {
            "value": "Esbelto",
            "label": "Esbelto"
          },
          {
            "value": "Atlético",
            "label": "Atlético"
          },
          {
            "value": "Tonificado",
            "label": "Tonificado"
          },
          {
            "value": "Musculoso",
            "label": "Musculoso"
          },
          {
            "value": "Robusto",
            "label": "Robusto"
          },
          {
            "value": "Corpulento",
            "label": "Corpulento"
          }
        ],
        "default": ""
      },
      {
        "key": "apariencia.altura",
        "label": "Altura (cm)",
        "type": "number",
        "multiline": false
      },
      {
        "key": "apariencia.peso",
        "label": "Peso (kg)",
        "type": "number",
        "multiline": false
      },
      {
        "key": "apariencia.silueta",
        "label": "Silueta",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Triángulo invertido",
            "label": "Triángulo invertido"
          },
          {
            "value": "Trapezoidal",
            "label": "Trapezoidal"
          },
          {
            "value": "Rectangular",
            "label": "Rectangular"
          },
          {
            "value": "Triangular",
            "label": "Triangular"
          },
          {
            "value": "Ovalado",
            "label": "Ovalado"
          }
        ],
        "default": ""
      },
      {
        "key": "anatomia.genitales.pene.longitud",
        "label": "Pene · Longitud",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "5",
            "label": "5 cm — Chico"
          },
          {
            "value": "6",
            "label": "6 cm — Chico"
          },
          {
            "value": "7",
            "label": "7 cm — Chico"
          },
          {
            "value": "8",
            "label": "8 cm — Chico"
          },
          {
            "value": "9",
            "label": "9 cm — Chico"
          },
          {
            "value": "10",
            "label": "10 cm — Chico"
          },
          {
            "value": "11",
            "label": "11 cm — Chico"
          },
          {
            "value": "12",
            "label": "12 cm — Promedio"
          },
          {
            "value": "13",
            "label": "13 cm — Promedio"
          },
          {
            "value": "14",
            "label": "14 cm — Promedio"
          },
          {
            "value": "15",
            "label": "15 cm — Grande"
          },
          {
            "value": "16",
            "label": "16 cm — Grande"
          },
          {
            "value": "17",
            "label": "17 cm — Grande"
          },
          {
            "value": "18",
            "label": "18 cm — Grande"
          },
          {
            "value": "19",
            "label": "19 cm — Grande"
          },
          {
            "value": "20",
            "label": "20 cm — Muy grande"
          },
          {
            "value": "21",
            "label": "21 cm — Muy grande"
          },
          {
            "value": "22",
            "label": "22 cm — Muy grande"
          },
          {
            "value": "23",
            "label": "23 cm — Muy grande"
          },
          {
            "value": "24",
            "label": "24 cm — Muy grande"
          },
          {
            "value": "25",
            "label": "25 cm — Muy grande"
          },
          {
            "value": "26",
            "label": "26 cm — Muy grande"
          },
          {
            "value": "27",
            "label": "27 cm — Muy grande"
          },
          {
            "value": "28",
            "label": "28 cm — Muy grande"
          },
          {
            "value": "29",
            "label": "29 cm — Muy grande"
          },
          {
            "value": "30",
            "label": "30 cm — Muy grande"
          }
        ],
        "default": ""
      },
      {
        "key": "anatomia.genitales.pene.circunferencia",
        "label": "Pene · Grosor / circunferencia",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "7",
            "label": "7 cm — Delgado"
          },
          {
            "value": "8",
            "label": "8 cm — Delgado"
          },
          {
            "value": "9",
            "label": "9 cm — Delgado"
          },
          {
            "value": "10",
            "label": "10 cm — Promedio"
          },
          {
            "value": "11",
            "label": "11 cm — Promedio"
          },
          {
            "value": "12",
            "label": "12 cm — Promedio"
          },
          {
            "value": "13",
            "label": "13 cm — Grueso"
          },
          {
            "value": "14",
            "label": "14 cm — Grueso"
          },
          {
            "value": "15",
            "label": "15 cm — Grueso"
          },
          {
            "value": "16",
            "label": "16 cm — Muy grueso"
          },
          {
            "value": "17",
            "label": "17 cm — Muy grueso"
          },
          {
            "value": "18",
            "label": "18 cm — Muy grueso"
          }
        ],
        "default": ""
      },
      {
        "key": "anatomia.genitales.pene.forma",
        "label": "Pene · Forma del pene",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Recto",
            "label": "Recto"
          },
          {
            "value": "Curvado hacia arriba",
            "label": "Curvado hacia arriba"
          },
          {
            "value": "Curvado hacia abajo",
            "label": "Curvado hacia abajo"
          },
          {
            "value": "Curvado hacia la izquierda",
            "label": "Curvado hacia la izquierda"
          },
          {
            "value": "Curvado hacia la derecha",
            "label": "Curvado hacia la derecha"
          }
        ],
        "default": ""
      },
      {
        "key": "anatomia.genitales.pene.forma_glande",
        "label": "Pene · Forma del glande",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Redondeado",
            "label": "Redondeado"
          },
          {
            "value": "Ovalado",
            "label": "Ovalado"
          },
          {
            "value": "Cónico",
            "label": "Cónico"
          },
          {
            "value": "Acampanado",
            "label": "Acampanado"
          },
          {
            "value": "Pronunciado",
            "label": "Pronunciado"
          }
        ],
        "default": ""
      },
      {
        "key": "anatomia.genitales.vello_pubico.presencia",
        "label": "Vello púbico · Presencia",
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
        "default": ""
      },
      {
        "key": "anatomia.genitales.vello_pubico.estilo",
        "label": "Vello púbico · Estilo / distribución",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
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
        "default": ""
      },
      {
        "key": "anatomia.genitales.vello_pubico.color",
        "label": "Vello púbico · Color",
        "type": "text",
        "multiline": false
      },
      {
        "key": "apariencia.cabello.color",
        "label": "Cabello · color",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Negro",
            "label": "Negro"
          },
          {
            "value": "Castaño oscuro",
            "label": "Castaño oscuro"
          },
          {
            "value": "Castaño",
            "label": "Castaño"
          },
          {
            "value": "Castaño claro",
            "label": "Castaño claro"
          },
          {
            "value": "Rubio oscuro",
            "label": "Rubio oscuro"
          },
          {
            "value": "Rubio",
            "label": "Rubio"
          },
          {
            "value": "Rubio claro",
            "label": "Rubio claro"
          },
          {
            "value": "Platino",
            "label": "Platino"
          },
          {
            "value": "Pelirrojo",
            "label": "Pelirrojo"
          },
          {
            "value": "Gris",
            "label": "Gris"
          },
          {
            "value": "Blanco",
            "label": "Blanco"
          },
          {
            "value": "Azul",
            "label": "Azul"
          },
          {
            "value": "Rojo",
            "label": "Rojo"
          },
          {
            "value": "Rosa",
            "label": "Rosa"
          },
          {
            "value": "Morado",
            "label": "Morado"
          },
          {
            "value": "Verde",
            "label": "Verde"
          },
          {
            "value": "Otro",
            "label": "Otro"
          }
        ],
        "default": ""
      },
      {
        "key": "apariencia.cabello.longitud",
        "label": "Cabello · longitud",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Rapado",
            "label": "Rapado"
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
            "value": "Medio-largo",
            "label": "Medio-largo"
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
        "default": ""
      },
      {
        "key": "apariencia.cabello.corte_estilo",
        "label": "Corte / estilo",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Buzz Cut",
            "label": "Buzz Cut"
          },
          {
            "value": "Crew Cut",
            "label": "Crew Cut"
          },
          {
            "value": "Ivy League",
            "label": "Ivy League"
          },
          {
            "value": "Caesar",
            "label": "Caesar"
          },
          {
            "value": "French Crop",
            "label": "French Crop"
          },
          {
            "value": "Taper",
            "label": "Taper"
          },
          {
            "value": "Taper Fade",
            "label": "Taper Fade"
          },
          {
            "value": "Low Fade",
            "label": "Low Fade"
          },
          {
            "value": "Mid Fade",
            "label": "Mid Fade"
          },
          {
            "value": "High Fade",
            "label": "High Fade"
          },
          {
            "value": "Skin Fade",
            "label": "Skin Fade"
          },
          {
            "value": "Undercut",
            "label": "Undercut"
          },
          {
            "value": "Two Block",
            "label": "Two Block"
          },
          {
            "value": "Side Part",
            "label": "Side Part"
          },
          {
            "value": "Comb Over",
            "label": "Comb Over"
          },
          {
            "value": "Slick Back",
            "label": "Slick Back"
          },
          {
            "value": "Quiff",
            "label": "Quiff"
          },
          {
            "value": "Pompadour",
            "label": "Pompadour"
          },
          {
            "value": "Curtains",
            "label": "Curtains"
          },
          {
            "value": "Bro Flow",
            "label": "Bro Flow"
          },
          {
            "value": "Wolf Cut",
            "label": "Wolf Cut"
          },
          {
            "value": "Shag",
            "label": "Shag"
          },
          {
            "value": "Mullet",
            "label": "Mullet"
          },
          {
            "value": "Mohawk",
            "label": "Mohawk"
          },
          {
            "value": "Faux Hawk",
            "label": "Faux Hawk"
          },
          {
            "value": "Man Bun",
            "label": "Man Bun"
          },
          {
            "value": "Top Knot",
            "label": "Top Knot"
          },
          {
            "value": "Afro",
            "label": "Afro"
          },
          {
            "value": "Trenzas",
            "label": "Trenzas"
          },
          {
            "value": "Dreadlocks",
            "label": "Dreadlocks"
          }
        ],
        "default": ""
      },
      {
        "key": "apariencia.cabello.fleco",
        "label": "Fleco",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Sin fleco",
            "label": "Sin fleco"
          },
          {
            "value": "Corto",
            "label": "Corto"
          },
          {
            "value": "Recto",
            "label": "Recto"
          },
          {
            "value": "De lado",
            "label": "De lado"
          },
          {
            "value": "Largo",
            "label": "Largo"
          },
          {
            "value": "Dividido / Curtain",
            "label": "Dividido / Curtain"
          },
          {
            "value": "Desfilado",
            "label": "Desfilado"
          },
          {
            "value": "Texturizado",
            "label": "Texturizado"
          },
          {
            "value": "Messy",
            "label": "Messy"
          }
        ],
        "default": ""
      },
      {
        "key": "apariencia.ojos.color",
        "label": "Ojos · color",
        "type": "select",
        "multiline": false,
        "options": [
          {
            "value": "",
            "label": "Sin especificar"
          },
          {
            "value": "Negro",
            "label": "Negro"
          },
          {
            "value": "Marrón oscuro",
            "label": "Marrón oscuro"
          },
          {
            "value": "Marrón",
            "label": "Marrón"
          },
          {
            "value": "Marrón claro",
            "label": "Marrón claro"
          },
          {
            "value": "Ámbar",
            "label": "Ámbar"
          },
          {
            "value": "Avellana",
            "label": "Avellana"
          },
          {
            "value": "Verde",
            "label": "Verde"
          },
          {
            "value": "Azul",
            "label": "Azul"
          },
          {
            "value": "Azul claro",
            "label": "Azul claro"
          },
          {
            "value": "Gris",
            "label": "Gris"
          },
          {
            "value": "Heterocromía",
            "label": "Heterocromía"
          },
          {
            "value": "Otro",
            "label": "Otro"
          }
        ],
        "default": ""
      },
      {
        "key": "apariencia.ojos.forma",
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
            "value": "Redondos",
            "label": "Redondos"
          },
          {
            "value": "Alargados",
            "label": "Alargados"
          },
          {
            "value": "Rasgados",
            "label": "Rasgados"
          },
          {
            "value": "Hundidos",
            "label": "Hundidos"
          },
          {
            "value": "Prominentes",
            "label": "Prominentes"
          },
          {
            "value": "Monólidos",
            "label": "Monólidos"
          },
          {
            "value": "Encapuchados",
            "label": "Encapuchados"
          },
          {
            "value": "Caídos",
            "label": "Caídos"
          },
          {
            "value": "Ascendentes",
            "label": "Ascendentes"
          }
        ],
        "default": ""
      },
      {
        "key": "apariencia.forma_rostro",
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
            "value": "Ovalado",
            "label": "Ovalado"
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
        "default": ""
      },
      {
        "key": "apariencia.detalles_faciales",
        "label": "Detalles faciales",
        "type": "text",
        "multiline": true
      }
    ]
  },
  {
    "id": "vestimenta-inicial",
    "title": "👕 3 · Vestimenta inicial",
    "advanced": false,
    "fields": [
      {
        "key": "initial_outfit.parte_superior",
        "label": "Parte superior",
        "type": "text",
        "multiline": false
      },
      {
        "key": "initial_outfit.parte_inferior",
        "label": "Parte inferior",
        "type": "text",
        "multiline": false
      },
      {
        "key": "initial_outfit.calzado",
        "label": "Calzado",
        "type": "text",
        "multiline": false
      },
      {
        "key": "initial_outfit.ropa_interior",
        "label": "Ropa interior",
        "type": "text",
        "multiline": false
      },
      {
        "key": "initial_outfit.accesorios",
        "label": "Accesorios",
        "type": "text",
        "multiline": false
      },
      {
        "key": "initial_outfit.descripcion",
        "label": "Detalles adicionales",
        "type": "text",
        "multiline": true
      }
    ]
  },
  {
    "id": "personalidad",
    "title": "🧠 4 · Personalidad",
    "advanced": false,
    "fields": [
      {
        "key": "personality.descripcion",
        "label": "Descripción de personalidad",
        "type": "text",
        "multiline": true
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
    ]
  },
  {
    "id": "contexto",
    "title": "🌎 5 · Historia y contexto",
    "advanced": false,
    "fields": [
      {
        "key": "history.biografia",
        "label": "Historia / antecedentes",
        "type": "text",
        "multiline": true
      },
      {
        "key": "context.situacion",
        "label": "Situación actual",
        "type": "text",
        "multiline": true
      },
      {
        "key": "context.motivaciones_objetivos",
        "label": "Motivaciones / objetivos",
        "type": "text",
        "multiline": true
      }
    ]
  },
  {
    "id": "sexualidad",
    "title": "🔥 6 · Sexualidad e intimidad",
    "advanced": false,
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
        "default": ""
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
          },
          {
            "value": "user_demo_001",
            "label": "Perfil {{user}} de ejemplo"
          }
        ],
        "default": "",
        "target": "user"
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
          },
          {
            "value": "char_demo_001",
            "label": "{{char}} de ejemplo"
          }
        ],
        "default": "",
        "target": "char"
      },
      {
        "key": "sexuality.first_experience.with.unregistered_name",
        "label": "Nombre del personaje",
        "type": "text",
        "multiline": false,
        "target": "unregistered"
      },
      {
        "key": "sexuality.first_experience.backstory",
        "label": "Backstory de la primera vez",
        "type": "text",
        "multiline": true
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
        "default": ""
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
        "default": ""
      },
      {
        "key": "sexuality.preferences_interests",
        "label": "Preferencias e intereses sexuales",
        "type": "text",
        "multiline": true
      },
      {
        "key": "sexuality.limits",
        "label": "Límites sexuales",
        "type": "text",
        "multiline": true
      }
    ]
  },
  {
    "id": "reluser",
    "title": "❤️ 7 · Relación con {{user}}",
    "advanced": false,
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
        "default": "none"
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
        ]
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
        ]
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
        ]
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
        ]
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
        ]
      },
      {
        "key": "relationship_scenario.custom_name",
        "label": "Nombre del escenario personalizado",
        "type": "text",
        "multiline": false,
        "scenario": [
          "custom"
        ]
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
        "default": "Sin especificar"
      },
      {
        "key": "relation_user.actitud",
        "label": "Actitud",
        "type": "text",
        "multiline": true
      },
      {
        "key": "relation_user.pensamientos",
        "label": "Pensamientos",
        "type": "text",
        "multiline": true
      },
      {
        "key": "relation_user.sentimientos",
        "label": "Sentimientos",
        "type": "text",
        "multiline": true
      },
      {
        "key": "relation_user.deseos",
        "label": "Deseos",
        "type": "text",
        "multiline": true
      },
      {
        "key": "relation_user.intenciones",
        "label": "Intenciones",
        "type": "text",
        "multiline": true
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
    ]
  },
  {
    "id": "relchars",
    "title": "🔗 8 · Relaciones con otros personajes",
    "advanced": true,
    "fields": []
  },
  {
    "id": "mensajes",
    "title": "💬 9 · Mensajes",
    "advanced": false,
    "fields": [
      {
        "key": "messages.initial",
        "label": "Mensaje inicial",
        "type": "text",
        "multiline": true
      }
    ]
  },
  {
    "id": "expresion",
    "title": "🗣️ 10 · Expresión y comunicación",
    "advanced": true,
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
        "default": "Español"
      },
      {
        "key": "expression.language.accent",
        "label": "Acento",
        "type": "text",
        "multiline": false
      },
      {
        "key": "expression.language.use",
        "label": "Uso",
        "type": "text",
        "multiline": false
      },
      {
        "key": "expression.language.switch_rules",
        "label": "Reglas de cambio de idioma",
        "type": "text",
        "multiline": true
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
        "default": "Sin especificar"
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
        "default": "Sin especificar"
      },
      {
        "key": "expression.speech.style",
        "label": "Estilo",
        "type": "text",
        "multiline": false
      },
      {
        "key": "expression.speech.vocabulary",
        "label": "Vocabulario",
        "type": "text",
        "multiline": false
      },
      {
        "key": "expression.speech.fillers",
        "label": "Muletillas",
        "type": "text",
        "multiline": true
      },
      {
        "key": "expression.speech.expressions",
        "label": "Expresiones habituales",
        "type": "text",
        "multiline": true
      },
      {
        "key": "expression.speech.address_user",
        "label": "Forma de dirigirse a {{user}}",
        "type": "text",
        "multiline": true
      },
      {
        "key": "expression.behavior.gestures",
        "label": "Gestos habituales",
        "type": "text",
        "multiline": true
      },
      {
        "key": "expression.behavior.body_language",
        "label": "Lenguaje corporal",
        "type": "text",
        "multiline": true
      },
      {
        "key": "expression.behavior.posture",
        "label": "Postura habitual",
        "type": "text",
        "multiline": true
      },
      {
        "key": "expression.behavior.quirks",
        "label": "Manías / peculiaridades",
        "type": "text",
        "multiline": true
      }
    ]
  },
  {
    "id": "bot",
    "title": "⚙️ 11 · Respuestas del bot",
    "advanced": true,
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
        "default": "Media"
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
        "default": "Medio"
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
        "default": "Equilibrado"
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
        "default": "Primera persona"
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
        "default": "Diálogo + acciones"
      },
      {
        "key": "bot.additional",
        "label": "Instrucciones adicionales",
        "type": "text",
        "multiline": true
      }
    ]
  }
]''') as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
