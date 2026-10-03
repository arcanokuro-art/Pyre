import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/gallery_editor_section.dart';
import '../widgets/lorebook_binding_section.dart';
import 'persona_editor.dart';

/// Native editor for the approved seven-section {{user}} Hombre schema.
/// Reuses the legacy editor only for avatar handling while this screen owns
/// the structured profile fields and persistence.
class MalePersonaEditorScreen extends StatefulWidget {
  const MalePersonaEditorScreen({super.key});
  @override State<MalePersonaEditorScreen> createState()=>_MalePersonaEditorState();
}
class _MalePersonaEditorState extends State<MalePersonaEditorScreen>{
  final fields=<String,TextEditingController>{};
  final traits=<TextEditingController>[TextEditingController()];
  final occupations=<Map<String,TextEditingController>>[];
  final preferences=<Map<String,TextEditingController>>[];
  final events=<Map<String,TextEditingController>>[];
  final lorebooks=<String>[]; final gallery=<String>[]; bool isDefault=false;
  TextEditingController c(String k)=>fields.putIfAbsent(k,()=>TextEditingController());
  String v(String k)=>c(k).text.trim();
  Map<String,TextEditingController> row(List<String> ks)=>{for(final k in ks) k:TextEditingController()};
  @override void initState(){super.initState();occupations.add(row(['job','org','role','skills','details']));preferences.add(row(['type','name','description'])..['type']!.text='Preferencia');events.add(row(['name','description']));}
  Widget f(String k,String label,{int lines=1,String? suffix})=>Padding(padding:const EdgeInsets.only(bottom:10),child:TextField(controller:c(k),maxLines:lines,decoration:InputDecoration(labelText:label,suffixText:suffix)));
  Widget s(String title,List<Widget> children)=>Card(child:ExpansionTile(initiallyExpanded:title.startsWith('1'),title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),children:[Padding(padding:const EdgeInsets.all(14),child:Column(children:children))]));
  Widget rows(List<Map<String,TextEditingController>> list,List<String> keys,VoidCallback add)=>Column(children:[...list.map((r)=>Card(child:Padding(padding:const EdgeInsets.all(8),child:Column(children:keys.map((k)=>TextField(controller:r[k],maxLines:k=='description'||k=='details'?3:1,decoration:InputDecoration(labelText:k))).toList()))),TextButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('Añadir'))]);
  Map<String,dynamic> profile()=>{
    'identidad':{'nombre':v('nombre'),'apellido':v('apellido'),'apodo':v('apodo'),'edad':v('edad'),'genero':'hombre','etnia':v('etnia'),'nacionalidad':v('nacionalidad')},
    'apariencia':{'tono_piel':v('piel'),'complexion':v('complexion'),'altura':v('altura'),'peso':v('peso'),'silueta':v('silueta'),'anatomia':{'genitales':{'pene':{'longitud':v('longitud'),'circunferencia':v('circunferencia'),'forma':v('forma'),'forma_glande':v('glande')},'vello_pubico':{'presencia':v('vello_presencia'),'estilo':v('vello_estilo'),'color':v('vello_color')}}},'cabello':{'color':v('cabello_color'),'longitud':v('cabello_longitud'),'corte_estilo':v('cabello_corte'),'fleco':v('fleco')},'ojos':{'color':v('ojos_color'),'forma':v('ojos_forma')},'forma_rostro':v('rostro'),'detalles_faciales':v('faciales')},
    'vestimenta':{'parte_superior':v('superior'),'parte_inferior':v('inferior'),'calzado':v('calzado'),'ropa_interior':v('ropa_interior'),'accesorios':v('accesorios'),'descripcion':v('vest_desc')},
    'personalidad':{'descripcion':v('personalidad'),'rasgos':traits.map((e)=>e.text.trim()).where((e)=>e.isNotEmpty).toList(),'gustos':v('gustos'),'disgustos':v('disgustos')},
    'ocupaciones_actividades':occupations.map((r)=>{'ocupacion_profesion':r['job']!.text.trim(),'organizacion_institucion':r['org']!.text.trim(),'cargo_posicion':r['role']!.text.trim(),'especialidades_habilidades':r['skills']!.text.split(',').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList(),'detalles':r['details']!.text.trim()}).toList(),
    'sexualidad_intimidad':{'orientacion_sexual':'heterosexual','preferencias_fetiches':preferences.map((r)=>{'tipo':r['type']!.text.trim(),'nombre':r['name']!.text.trim(),'descripcion':r['description']!.text.trim()}).toList(),'detalles_adicionales':v('intimidad_detalles')},
    'historia_biografia':{'origen':v('origen'),'historia_personal':v('historia'),'acontecimientos_importantes':events.map((r)=>{'nombre':r['name']!.text.trim(),'descripcion':r['description']!.text.trim()}).toList(),'detalles_adicionales':v('hist_detalles')}};
  void save(){final p=profile();final name=v('apodo').isNotEmpty?v('apodo'):[v('nombre'),v('apellido')].where((e)=>e.isNotEmpty).join(' ');if(name.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Nombre requerido')));return;}final persona=Persona(id:newId('persona'),name:name,description:const JsonEncoder.withIndent('  ').convert(p),structuredProfile:p,lorebookIds:List.from(lorebooks),gallery:List.from(gallery));final st=context.read<AppStore>();st.addPersona(persona);if(isDefault)st.setActivePersona(persona.id);Navigator.pop(context);}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('{{user}} Hombre'),actions:[TextButton(onPressed:save,child:const Text('Save'))]),body:ListView(padding:const EdgeInsets.all(16),children:[
    Card(child:ListTile(title:const Text('Avatar'),subtitle:const Text('Change / Recrop'),trailing:const Icon(Icons.chevron_right),onTap:()=>showPersonaEditor(context))),
    s('1 · Perfil',[f('nombre','Nombre'),f('apellido','Apellido'),f('apodo','Apodo'),f('edad','Edad'),const ListTile(title:Text('Género'),subtitle:Text('Hombre 🔒')),f('etnia','Etnia'),f('nacionalidad','Nacionalidad')]),
    s('2 · Apariencia',[f('piel','Tono de piel'),f('complexion','Complexión'),f('altura','Altura',suffix:'cm'),f('peso','Peso',suffix:'kg'),f('silueta','Silueta'),f('longitud','Longitud'),f('circunferencia','Grosor / circunferencia'),f('forma','Forma del pene'),f('glande','Forma del glande'),f('vello_presencia','Vello púbico'),f('vello_estilo','Estilo'),f('vello_color','Color'),f('cabello_color','Color de cabello'),f('cabello_longitud','Longitud de cabello'),f('cabello_corte','Corte / estilo'),f('fleco','Fleco'),f('ojos_color','Color de ojos'),f('ojos_forma','Forma de ojos'),f('rostro','Forma del rostro'),f('faciales','Detalles faciales',lines:4)]),
    s('3 · Vestimenta',[f('superior','Parte superior'),f('inferior','Parte inferior'),f('calzado','Calzado'),f('ropa_interior','Ropa interior'),f('accesorios','Accesorios'),f('vest_desc','Detalles adicionales',lines:4)]),
    s('4 · Personalidad',[f('personalidad','Personalidad general',lines:5),...traits.map((e)=>TextField(controller:e,decoration:const InputDecoration(labelText:'Rasgo'))),TextButton.icon(onPressed:()=>setState(()=>traits.add(TextEditingController())),icon:const Icon(Icons.add),label:const Text('Añadir rasgo')),f('gustos','Gustos',lines:3),f('disgustos','Disgustos',lines:3)]),
    s('5 · Ocupación / Actividad',[rows(occupations,['job','org','role','skills','details'],()=>setState(()=>occupations.add(row(['job','org','role','skills','details']))))]),
    s('6 · Sexualidad e intimidad',[const ListTile(title:Text('Orientación sexual'),subtitle:Text('Heterosexual 🔒')),rows(preferences,['type','name','description'],()=>setState(()=>preferences.add(row(['type','name','description'])..['type']!.text='Preferencia')),f('intimidad_detalles','Detalles adicionales',lines:4)]),
    s('7 · Historia / Biografía',[f('origen','Origen',lines:3),f('historia','Historia personal',lines:5),rows(events,['name','description'],()=>setState(()=>events.add(row(['name','description']))),f('hist_detalles','Detalles adicionales',lines:4)]),
    LorebookBindingSection(selectedIds:lorebooks,onChanged:(n)=>setState(()=>{lorebooks..clear()..addAll(n)}),sublabel:'Active with this persona.'),
    GalleryEditorSection(gallery:gallery,onChanged:(n)=>setState(()=>{gallery..clear()..addAll(n)})),
    CheckboxListTile(title:const Text('Set as default persona'),value:isDefault,activeColor:EmberColors.primary,onChanged:(n)=>setState(()=>isDefault=n??false)),
    ElevatedButton(onPressed:save,child:const Text('Save persona')),const SizedBox(height:32)]));
}