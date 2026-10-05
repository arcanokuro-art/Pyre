import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/attachment_store.dart';
import '../services/image_pick.dart';
import '../state/app_store.dart';
import '../services/structured_persona_prompt.dart';
import '../theme.dart';
import '../widgets/gallery_editor_section.dart';
import '../widgets/lorebook_binding_section.dart';
import 'avatar_crop_screen.dart';

/// Native editor for the approved seven-section {{user}} Hombre schema.
/// Owns the structured profile, avatar/recrop flow, bound lorebooks, gallery,
/// default-persona state, and persistence without routing through the legacy editor.
class MalePersonaEditorScreen extends StatefulWidget {
  final Persona? existing;
  const MalePersonaEditorScreen({super.key, this.existing});
  @override State<MalePersonaEditorScreen> createState()=>_MalePersonaEditorState();
}
class _MalePersonaEditorState extends State<MalePersonaEditorScreen>{
  final fields=<String,TextEditingController>{};
  final traits=<TextEditingController>[TextEditingController()];
  final occupations=<Map<String,TextEditingController>>[];
  final occupationSkills=<List<TextEditingController>>[];
  final preferences=<Map<String,TextEditingController>>[];
  final events=<Map<String,TextEditingController>>[];
  final lorebooks=<String>[]; final gallery=<String>[]; bool isDefault=false;
  String? avatar, avatarOriginal;
  TextEditingController c(String k)=>fields.putIfAbsent(k,()=>TextEditingController());
  String v(String k)=>c(k).text.trim();
  Map<String,TextEditingController> row(List<String> ks)=>{for(final k in ks) k:TextEditingController()};
  @override void initState(){super.initState();final p=widget.existing;avatar=p?.avatar;avatarOriginal=p?.avatarOriginal;if(p!=null){lorebooks.addAll(p.lorebookIds);gallery.addAll(p.gallery);isDefault=p.id==context.read<AppStore>().activePersonaId;_loadProfile(p.structuredProfile);}if(occupations.isEmpty){occupations.add(row(['job','org','role','details']));occupationSkills.add([TextEditingController()]);}if(preferences.isEmpty)preferences.add(row(['type','name','description'])..['type']!.text='Preferencia');if(events.isEmpty)events.add(row(['name','description']));}
  dynamic _at(Map<String,dynamic> root,List<String> path){dynamic value=root;for(final key in path){if(value is! Map)return null;value=value[key];}return value;}
  void _seed(Map<String,dynamic> root,String key,List<String> path){final value=_at(root,path);if(value!=null)c(key).text=value.toString();}
  void _loadProfile(Map<String,dynamic> p){if(p.isEmpty)return;final paths=<String,List<String>>{
    'nombre':['identidad','nombre'],'apellido':['identidad','apellido'],'apodo':['identidad','apodo'],'edad':['identidad','edad'],'etnia':['identidad','etnia'],'nacionalidad':['identidad','nacionalidad'],
    'piel':['apariencia','tono_piel'],'complexion':['apariencia','complexion'],'altura':['apariencia','altura'],'peso':['apariencia','peso'],'silueta':['apariencia','silueta'],
    'longitud':['apariencia','anatomia','genitales','pene','longitud'],'circunferencia':['apariencia','anatomia','genitales','pene','circunferencia'],'forma':['apariencia','anatomia','genitales','pene','forma'],'glande':['apariencia','anatomia','genitales','pene','forma_glande'],
    'vello_presencia':['apariencia','anatomia','genitales','vello_pubico','presencia'],'vello_estilo':['apariencia','anatomia','genitales','vello_pubico','estilo'],'vello_color':['apariencia','anatomia','genitales','vello_pubico','color'],
    'cabello_color':['apariencia','cabello','color'],'cabello_longitud':['apariencia','cabello','longitud'],'cabello_corte':['apariencia','cabello','corte_estilo'],'fleco':['apariencia','cabello','fleco'],
    'ojos_color':['apariencia','ojos','color'],'ojos_forma':['apariencia','ojos','forma'],'rostro':['apariencia','forma_rostro'],'faciales':['apariencia','detalles_faciales'],
    'superior':['vestimenta','parte_superior'],'inferior':['vestimenta','parte_inferior'],'calzado':['vestimenta','calzado'],'ropa_interior':['vestimenta','ropa_interior'],'accesorios':['vestimenta','accesorios'],'vest_desc':['vestimenta','descripcion'],
    'personalidad':['personalidad','descripcion'],'gustos':['personalidad','gustos'],'disgustos':['personalidad','disgustos'],'intimidad_detalles':['sexualidad_intimidad','detalles_adicionales'],
    'origen':['historia_biografia','origen'],'historia':['historia_biografia','historia_personal'],'hist_detalles':['historia_biografia','detalles_adicionales']};
    for(final e in paths.entries)_seed(p,e.key,e.value);
    final rs=_at(p,['personalidad','rasgos']);if(rs is List){traits.first.dispose();traits.clear();for(final value in rs)traits.add(TextEditingController(text:value.toString()));if(traits.isEmpty)traits.add(TextEditingController());}
    final os=p['ocupaciones_actividades'];if(os is List){for(final raw in os.whereType<Map>()){final r=row(['job','org','role','details']);r['job']!.text=(raw['ocupacion_profesion']??'').toString();r['org']!.text=(raw['organizacion_institucion']??'').toString();r['role']!.text=(raw['cargo_posicion']??'').toString();r['details']!.text=(raw['detalles']??'').toString();occupations.add(r);final sk=raw['especialidades_habilidades'];final skillControllers=<TextEditingController>[];if(sk is List){for(final skill in sk){skillControllers.add(TextEditingController(text:skill.toString()));}}occupationSkills.add(skillControllers.isEmpty?[TextEditingController()]:skillControllers);}}
    final ps=_at(p,['sexualidad_intimidad','preferencias_fetiches']);if(ps is List){for(final raw in ps.whereType<Map>()){final r=row(['type','name','description']);r['type']!.text=(raw['tipo']??'Preferencia').toString();r['name']!.text=(raw['nombre']??'').toString();r['description']!.text=(raw['descripcion']??'').toString();preferences.add(r);}}
    final es=_at(p,['historia_biografia','acontecimientos_importantes']);if(es is List){for(final raw in es.whereType<Map>()){final r=row(['name','description']);r['name']!.text=(raw['nombre']??'').toString();r['description']!.text=(raw['descripcion']??'').toString();events.add(r);}}
  }
  @override void dispose(){for(final x in fields.values)x.dispose();for(final x in traits)x.dispose();for(final r in occupations){for(final x in r.values)x.dispose();}for(final skills in occupationSkills){for(final x in skills)x.dispose();}for(final r in preferences){for(final x in r.values)x.dispose();}for(final r in events){for(final x in r.values)x.dispose();}super.dispose();}
  Widget traitRows()=>Column(children:[
    ...traits.asMap().entries.map((entry)=>Row(children:[Expanded(child:TextField(controller:entry.value,decoration:InputDecoration(labelText:'Rasgo #${entry.key+1}'))),IconButton(tooltip:'Eliminar rasgo',icon:const Icon(Icons.remove_circle_outline),onPressed:traits.length<=1?null:()=>setState(()=>traits.removeAt(entry.key).dispose()))])),
    Align(alignment:Alignment.centerLeft,child:TextButton.icon(onPressed:()=>setState(()=>traits.add(TextEditingController())),icon:const Icon(Icons.add),label:const Text('Añadir rasgo')))
  ]);
  Future<void> changeAvatar()async{final p=await pickOneImage();if(p==null||!mounted)return;final r=await externalizeImageBytes(p.bytes);if(!mounted)return;setState((){avatar=r;avatarOriginal=null;});}
  Future<void> recrop()async{final src=avatarOriginal??avatar;if(src==null||src.isEmpty)return;final bytes=await resolveAvatarBytes(src);if(bytes==null||!mounted)return;final cropped=await cropAvatar(context,bytes);if(cropped==null)return;final r=await externalizeImageBytes(cropped);if(!mounted)return;setState((){avatarOriginal??=avatar;avatar=r;});}
  Widget f(String k,String label,{int lines=1,String? suffix})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c(k),maxLines:lines,decoration:InputDecoration(labelText:label,suffixText:suffix)));
  Widget nf(String k,String label,{String? suffix})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c(k),keyboardType:TextInputType.number,inputFormatters:[FilteringTextInputFormatter.digitsOnly],decoration:InputDecoration(labelText:label,suffixText:suffix)));
  Widget dd(String k,String label,List<String> options){final current=v(k);return Padding(padding:const EdgeInsets.only(bottom:10),child:DropdownButtonFormField<String>(value:options.contains(current)?current:null,isExpanded:true,decoration:InputDecoration(labelText:label),items:options.map((e)=>DropdownMenuItem(value:e,child:Text(e,overflow:TextOverflow.ellipsis))).toList(),onChanged:(next)=>setState(()=>c(k).text=next??'')));}
  Widget numberDd(String k,String label,int min,int max,String Function(int) category){final current=int.tryParse(v(k));return Padding(padding:const EdgeInsets.only(bottom:10),child:DropdownButtonFormField<int>(value:current!=null&&current>=min&&current<=max?current:null,isExpanded:true,decoration:InputDecoration(labelText:label),items:[for(var n=min;n<=max;n++)DropdownMenuItem(value:n,child:Text('$n cm — ${category(n)}'))],onChanged:(next)=>setState(()=>c(k).text=next?.toString()??'')));}
  Widget s(String title,List<Widget> children)=>Card(child:ExpansionTile(initiallyExpanded:title.startsWith('1'),title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),children:[Padding(padding:const EdgeInsets.all(14),child:Column(children:children))]));
  Widget rows(List<Map<String,TextEditingController>> list,List<String> keys,VoidCallback add,{Map<String,String> labels=const {},String? selectKey,List<String> selectOptions=const []})=>Column(children:[
    ...list.asMap().entries.map((entry){final i=entry.key;final r=entry.value;return Card(child:Padding(padding:const EdgeInsets.all(8),child:Column(children:[
      Row(children:[Expanded(child:Text('#${i+1}',style:const TextStyle(fontWeight:FontWeight.w600))),IconButton(tooltip:'Eliminar',icon:const Icon(Icons.delete_outline),onPressed:list.length<=1?null:()=>setState((){final removed=list.removeAt(i);for(final x in removed.values)x.dispose();}))]),
      ...keys.map((k){if(k==selectKey)return DropdownButtonFormField<String>(value:selectOptions.contains(r[k]!.text)?r[k]!.text:null,isExpanded:true,decoration:InputDecoration(labelText:labels[k]??k),items:selectOptions.map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(next)=>setState(()=>r[k]!.text=next??''));return TextField(controller:r[k],maxLines:k=='description'||k=='details'?3:1,decoration:InputDecoration(labelText:labels[k]??k));})
    ])));}),
    Align(alignment:Alignment.centerLeft,child:TextButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('Añadir')))
  ]);
  Widget occupationRows()=>Column(children:[
    ...occupations.asMap().entries.map((entry){final i=entry.key;final r=entry.value;final skills=occupationSkills[i];return Card(child:Padding(padding:const EdgeInsets.all(8),child:Column(children:[
      Row(children:[Expanded(child:Text('#${i+1}',style:const TextStyle(fontWeight:FontWeight.w600))),IconButton(tooltip:'Eliminar ocupación',icon:const Icon(Icons.delete_outline),onPressed:occupations.length<=1?null:()=>setState((){for(final x in r.values)x.dispose();for(final x in occupationSkills.removeAt(i))x.dispose();occupations.removeAt(i);}))]),
      TextField(controller:r['job'],decoration:const InputDecoration(labelText:'Ocupación / Profesión')),
      TextField(controller:r['org'],decoration:const InputDecoration(labelText:'Organización / Institución')),
      TextField(controller:r['role'],decoration:const InputDecoration(labelText:'Cargo / Posición')),
      const SizedBox(height:8),const Align(alignment:Alignment.centerLeft,child:Text('Especialidades / Habilidades')),
      ...skills.asMap().entries.map((skillEntry)=>Row(children:[Expanded(child:TextField(controller:skillEntry.value,decoration:InputDecoration(labelText:'Habilidad #${skillEntry.key+1}'))),IconButton(tooltip:'Eliminar habilidad',icon:const Icon(Icons.remove_circle_outline),onPressed:skills.length<=1?null:()=>setState(()=>skills.removeAt(skillEntry.key).dispose()))])),
      Align(alignment:Alignment.centerLeft,child:TextButton.icon(onPressed:()=>setState(()=>skills.add(TextEditingController())),icon:const Icon(Icons.add),label:const Text('Añadir habilidad'))),
      TextField(controller:r['details'],maxLines:3,decoration:const InputDecoration(labelText:'Detalles'))
    ])));}),
    Align(alignment:Alignment.centerLeft,child:TextButton.icon(onPressed:()=>setState((){occupations.add(row(['job','org','role','details']));occupationSkills.add([TextEditingController()]);}),icon:const Icon(Icons.add),label:const Text('Añadir ocupación / actividad')))
  ]);
  Map<String,dynamic> profile()=>{
    'identidad':{'nombre':v('nombre'),'apellido':v('apellido'),'apodo':v('apodo'),'edad':v('edad'),'genero':'hombre','etnia':v('etnia'),'nacionalidad':v('nacionalidad')},
    'apariencia':{'tono_piel':v('piel'),'complexion':v('complexion'),'altura':v('altura'),'peso':v('peso'),'silueta':v('silueta'),'anatomia':{'genitales':{'pene':{'longitud':v('longitud'),'circunferencia':v('circunferencia'),'forma':v('forma'),'forma_glande':v('glande')},'vello_pubico':{'presencia':v('vello_presencia'),'estilo':v('vello_estilo'),'color':v('vello_color')}}},'cabello':{'color':v('cabello_color'),'longitud':v('cabello_longitud'),'corte_estilo':v('cabello_corte'),'fleco':v('fleco')},'ojos':{'color':v('ojos_color'),'forma':v('ojos_forma')},'forma_rostro':v('rostro'),'detalles_faciales':v('faciales')},
    'vestimenta':{'parte_superior':v('superior'),'parte_inferior':v('inferior'),'calzado':v('calzado'),'ropa_interior':v('ropa_interior'),'accesorios':v('accesorios'),'descripcion':v('vest_desc')},
    'personalidad':{'descripcion':v('personalidad'),'rasgos':traits.map((e)=>e.text.trim()).where((e)=>e.isNotEmpty).toList(),'gustos':v('gustos'),'disgustos':v('disgustos')},
    'ocupaciones_actividades':[for(var i=0;i<occupations.length;i++){'ocupacion_profesion':occupations[i]['job']!.text.trim(),'organizacion_institucion':occupations[i]['org']!.text.trim(),'cargo_posicion':occupations[i]['role']!.text.trim(),'especialidades_habilidades':occupationSkills[i].map((e)=>e.text.trim()).where((e)=>e.isNotEmpty).toList(),'detalles':occupations[i]['details']!.text.trim()}],
    'sexualidad_intimidad':{'orientacion_sexual':'heterosexual','preferencias_fetiches':preferences.map((r)=>{'tipo':r['type']!.text.trim(),'nombre':r['name']!.text.trim(),'descripcion':r['description']!.text.trim()}).toList(),'detalles_adicionales':v('intimidad_detalles')},
    'historia_biografia':{'origen':v('origen'),'historia_personal':v('historia'),'acontecimientos_importantes':events.map((r)=>{'nombre':r['name']!.text.trim(),'descripcion':r['description']!.text.trim()}).toList(),'detalles_adicionales':v('hist_detalles')}};
  void save(){final p=profile();final name=v('apodo').isNotEmpty?v('apodo'):[v('nombre'),v('apellido')].where((e)=>e.isNotEmpty).join(' ');if(name.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Nombre requerido')));return;}final persona=widget.existing??Persona(id:newId('persona'),name:name);persona..name=name..description=buildStructuredPersonaPrompt(p)..structuredProfile=p..avatar=avatar..avatarOriginal=avatarOriginal..lorebookIds=List.from(lorebooks)..gallery=List.from(gallery);final st=context.read<AppStore>();widget.existing==null?st.addPersona(persona):st.updatePersona(persona);if(isDefault)st.setActivePersona(persona.id);Navigator.pop(context);}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('{{user}} Hombre'),actions:[TextButton(onPressed:save,child:const Text('Save'))]),body:ListView(padding:const EdgeInsets.all(16),children:[
    Card(child:ListTile(leading:CircleAvatar(child:Text(v('nombre').isEmpty?'?':v('nombre')[0])),title:const Text('Avatar'),subtitle:Text(avatar==null?'Sin avatar':'Avatar seleccionado'),trailing:Wrap(children:[TextButton(onPressed:changeAvatar,child:const Text('Change')),TextButton(onPressed:avatar==null?null:recrop,child:const Text('Recrop'))]))),
    s('1 · Perfil',[f('nombre','Nombre'),f('apellido','Apellido'),f('apodo','Apodo'),nf('edad','Edad'),const ListTile(title:Text('Género'),subtitle:Text('Hombre 🔒')),f('etnia','Etnia'),f('nacionalidad','Nacionalidad')]),
    s('2 · Apariencia',[
      dd('piel','Tono de piel',['Muy clara','Clara','Media','Oliva','Morena','Oscura']),
      dd('complexion','Complexión',['Delgado','Esbelto','Atlético','Tonificado','Musculoso','Robusto','Corpulento']),
      nf('altura','Altura',suffix:'cm'),nf('peso','Peso',suffix:'kg'),
      dd('silueta','Silueta',['Triángulo invertido','Trapezoidal','Rectangular','Triangular','Ovalado']),
      numberDd('longitud','Longitud',5,30,(n)=>n<=11?'Chico':n<=14?'Promedio':n<=19?'Grande':'Muy grande'),
      numberDd('circunferencia','Grosor / circunferencia',7,18,(n)=>n<=9?'Delgado':n<=12?'Promedio':n<=15?'Grueso':'Muy grueso'),
      dd('forma','Forma del pene',['Recto','Curvado hacia arriba','Curvado hacia abajo','Curvado hacia la izquierda','Curvado hacia la derecha']),
      dd('glande','Forma del glande',['Redondeado','Ovalado','Cónico','Acampanado','Pronunciado']),
      dd('vello_presencia','Vello púbico',['Sin especificar','No','Sí']),
      dd('vello_estilo','Estilo',['Sin especificar','Depilación completa','Recortado','Natural','Personalizado…']),f('vello_color','Color'),
      dd('cabello_color','Color de cabello',['Negro','Castaño oscuro','Castaño','Castaño claro','Rubio oscuro','Rubio','Rubio claro','Platino','Pelirrojo','Gris','Blanco','Azul','Rojo','Rosa','Morado','Verde','Otro']),
      dd('cabello_longitud','Longitud de cabello',['Rapado','Muy corto','Corto','Medio','Medio-largo','Largo','Muy largo']),
      dd('cabello_corte','Corte / estilo',['Buzz Cut','Crew Cut','Ivy League','Caesar','French Crop','Taper','Taper Fade','Low Fade','Mid Fade','High Fade','Skin Fade','Undercut','Two Block','Side Part','Comb Over','Slick Back','Quiff','Pompadour','Curtains','Bro Flow','Wolf Cut','Shag','Mullet','Mohawk','Faux Hawk','Man Bun','Top Knot','Afro','Trenzas','Dreadlocks']),
      dd('fleco','Fleco',['Sin fleco','Corto','Recto','De lado','Largo','Dividido / Curtain','Desfilado','Texturizado','Messy']),
      dd('ojos_color','Color de ojos',['Negro','Marrón oscuro','Marrón','Marrón claro','Ámbar','Avellana','Verde','Azul','Azul claro','Gris','Heterocromía','Otro']),
      dd('ojos_forma','Forma de ojos',['Almendrados','Redondos','Alargados','Rasgados','Hundidos','Prominentes','Monólidos','Encapuchados','Caídos','Ascendentes']),
      dd('rostro','Forma del rostro',['Redondo','Ovalado','Diamante','Cuadrado','Triangular A','Triangular V','Rectangular','Alargado','Corazón']),
      f('faciales','Detalles faciales',lines:4)]),
    s('3 · Vestimenta',[f('superior','Parte superior'),f('inferior','Parte inferior'),f('calzado','Calzado'),f('ropa_interior','Ropa interior'),f('accesorios','Accesorios'),f('vest_desc','Detalles adicionales',lines:4)]),
    s('4 · Personalidad',[f('personalidad','Personalidad general',lines:5),traitRows(),f('gustos','Gustos',lines:3),f('disgustos','Disgustos',lines:3)]),
    s('5 · Ocupación / Actividad',[occupationRows()]),
    s('6 · Sexualidad e intimidad',[const ListTile(title:Text('Orientación sexual'),subtitle:Text('Heterosexual 🔒')),rows(preferences,['type','name','description'],()=>setState(()=>preferences.add(row(['type','name','description'])..['type']!.text='Preferencia')),labels:{'type':'Tipo','name':'Nombre','description':'Descripción'},selectKey:'type',selectOptions:['Preferencia','Fetiche']),f('intimidad_detalles','Detalles adicionales',lines:4)]),
    s('7 · Historia / Biografía',[f('origen','Origen',lines:3),f('historia','Historia personal',lines:5),rows(events,['name','description'],()=>setState(()=>events.add(row(['name','description']))),labels:{'name':'Nombre del acontecimiento','description':'Descripción'}),f('hist_detalles','Detalles adicionales',lines:4)]),
    LorebookBindingSection(selectedIds:lorebooks,onChanged:(n)=>setState((){lorebooks..clear()..addAll(n);}),sublabel:'Active with this persona.'),
    GalleryEditorSection(gallery:gallery,onChanged:(n)=>setState((){gallery..clear()..addAll(n);}),onUseAsAvatar:(i)=>setState((){avatar=gallery[i];avatarOriginal=null;})),
    CheckboxListTile(title:const Text('Set as default persona'),value:isDefault,activeColor:EmberColors.primary,onChanged:(n)=>setState(()=>isDefault=n??false)),
    ElevatedButton(onPressed:save,child:const Text('Save persona')),const SizedBox(height:32)]));
}