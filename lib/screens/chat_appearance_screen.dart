import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../services/attachment_store.dart';
import '../services/image_pick.dart';
import '../state/app_store.dart';
import '../theme.dart';
import '../widgets/how_it_works_card.dart';
import '../widgets/bubble_color_row.dart';
import '../widgets/lightbox.dart';

class ChatAppearanceScreen extends StatefulWidget {
  const ChatAppearanceScreen({super.key});
  @override
  State<ChatAppearanceScreen> createState() => _ChatAppearanceScreenState();
}

class _ChatAppearanceScreenState extends State<ChatAppearanceScreen> {
  late ChatSettings _draft;
  bool get _es => AppStrings.of(context).es;
  String _t(String s, String e) => _es ? s : e;

  @override
  void initState() {
    super.initState();
    _draft = context.read<AppStore>().chatSettings.copyWith();
  }

  Future<void> _pickCustomBackground() async {
    final picked = await pickOneImage();
    if (picked == null || !mounted) return;
    final ref = await externalizeImageBytes(picked.bytes);
    if (!mounted) return;
    setState(() {
      _draft.customBackgroundDataUrl = ref;
      _draft.backgroundSource = ChatBackgroundSource.custom;
    });
    _commit();
  }

  void _commit() => context.read<AppStore>().updateChatSettings(_draft);

  String _bgLabel(ChatBackgroundSource s) {
    switch (s) {
      case ChatBackgroundSource.characterAvatar: return _t('Avatar del personaje', 'Character avatar');
      case ChatBackgroundSource.personaAvatar: return _t('Avatar de la persona', 'Persona avatar');
      case ChatBackgroundSource.custom: return _t('Imagen personalizada', 'Custom image');
      case ChatBackgroundSource.none: return _t('Ninguno — tema oscuro simple', 'None — plain dark theme');
      case ChatBackgroundSource.dynamic: return _t('Según la escena (dinámico)', 'Scene-aware (dynamic)');
    }
  }

  String _bgSubtitle(ChatBackgroundSource s) {
    switch (s) {
      case ChatBackgroundSource.characterAvatar: return _t('Predeterminado: el retrato del personaje principal aparece detrás del chat.', 'Default — the primary character\'s portrait sits behind the chat.');
      case ChatBackgroundSource.personaAvatar: return _t('Usa el avatar de tu persona activa. Si no hay una persona configurada, usa el personaje.', 'Your active persona\'s avatar instead. Falls back to character if no persona is set.');
      case ChatBackgroundSource.custom: return _t('Sube tu propia imagen (se guarda con los datos de la aplicación).', 'Upload your own image (saved with the app data).');
      case ChatBackgroundSource.none: return _t('Sin fondo: las burbujas aparecen sobre el fondo de la aplicación.', 'No backdrop — bubbles float over the app background.');
      case ChatBackgroundSource.dynamic: return _t('El fondo sigue automáticamente la escena conforme avanza la historia (usa tu modelo).', 'Background follows the scene automatically as the story moves (uses your model).');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('Personalizar chat', 'Customize Chat'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          HowItWorksCard(
            title: _t('Cómo funciona la personalización del chat', 'How customizing the chat works'),
            subtitle: _t('Burbujas, fondo y modo según la escena.', 'Bubbles, background, and the scene-aware mode.'),
            sections: _es ? const [
              HowItWorksSection('Qué es', [HowItWorksBlock.paragraph('Estos ajustes controlan la **apariencia** de todos los chats: el estilo de las burbujas, el fondo y si se muestra el razonamiento del modelo. Son valores globales; cada chat puede reemplazar su propio fondo desde su menú.')]),
              HowItWorksSection('Burbujas', [HowItWorksBlock.bullet('**Opacidad de burbuja** — controla qué tan visible es el fondo del mensaje sobre el fondo del chat.'), HowItWorksBlock.bullet('**Burbujas de mensajes** — colores separados para tus mensajes y los del personaje, radio de esquinas, borde, tamaño del texto y desenfoque del fondo.')]),
              HowItWorksSection('Fondo', [HowItWorksBlock.bullet('Elige entre el **avatar del personaje**, el **avatar de tu persona**, una **imagen personalizada** o **ninguno**.'), HowItWorksBlock.bullet('**Según la escena (dinámico)** — el fondo cambia automáticamente con la ubicación de la historia usando tu modelo.'), HowItWorksBlock.paragraph('Para actualizarlo manualmente, abre el menú ⋮ del chat → **Fondo del chat** y usa **Detectar ubicación desde el chat**.')]),
              HowItWorksSection('Razonamiento', [HowItWorksBlock.bullet('**Ocultar razonamiento del modelo** — oculta bloques <think>…</think> de modelos de razonamiento. Solo cambia lo que ves, no lo que genera el modelo.')]),
            ] : const [
              HowItWorksSection('What it is', [HowItWorksBlock.paragraph('These are the **looks** of every chat — how the message bubbles are styled, what sits behind them, and whether a reasoning model\'s thinking is shown. They\'re global defaults; a single chat can override its background from its own menu.')]),
              HowItWorksSection('Bubbles', [HowItWorksBlock.bullet('**Bubble opacity** — how visible the message background is over the chat backdrop.'), HowItWorksBlock.bullet('**Message bubbles** — separate colors for your and the character\'s bubbles, plus corner radius, border, text size, and a frosted-glass **background blur**.')]),
              HowItWorksSection('Background', [HowItWorksBlock.bullet('Pick the **character avatar**, your **persona avatar**, a **custom image**, or **none**.'), HowItWorksBlock.bullet('**Scene-aware (dynamic)** — the background follows the story automatically using your configured model.'), HowItWorksBlock.paragraph('To update it by hand, open the chat ⋮ menu → **Chat background** and use **Detect location from chat**.')]),
              HowItWorksSection('Reasoning', [HowItWorksBlock.bullet('**Hide model reasoning** — hides <think>…</think> blocks from reasoning models. It only changes what you see, not what the model generates.')]),
            ],
          ),
          const SizedBox(height: 8),
          Card(margin: const EdgeInsets.symmetric(vertical: 6), child: Padding(padding: const EdgeInsets.fromLTRB(16,12,16,8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_t('Opacidad de burbuja','Bubble opacity'), style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height:2), Text(_t('Qué tan visible es el fondo del mensaje sobre la imagen del personaje.','How visible the message background is over the character art.'), style: TextStyle(color: EmberColors.textMid,fontSize:12))])), Text('${(_draft.bubbleAlpha*100).round()}%', style: TextStyle(color:EmberColors.textMid,fontFeatures:[FontFeature.tabularFigures()]))]),
            Slider(value:_draft.bubbleAlpha,min:0,max:1,divisions:20,activeColor:EmberColors.primary,onChanged:(v)=>setState(()=>_draft.bubbleAlpha=v),onChangeEnd:(_)=>_commit()),
          ]))),
          Card(margin: const EdgeInsets.symmetric(vertical:6), child: Padding(padding: const EdgeInsets.fromLTRB(16,12,16,16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(_t('Burbujas de mensajes','Message bubbles'),style:const TextStyle(fontWeight:FontWeight.w600)), const SizedBox(height:2), Text(_t('Ajusta la apariencia de tus burbujas. Déjalo como está para conservar el estilo predeterminado.','Tune the look of your bubbles. Leave everything as-is for the default style.'),style:TextStyle(color:EmberColors.textMid,fontSize:12)), const SizedBox(height:16),
            Text(_t('Color de tu burbuja','Your bubble color'),style:const TextStyle(fontSize:13)), const SizedBox(height:6), BubbleColorRow(selected:_draft.userBubbleColor,palette:kBubbleColorPalette,onPick:(v){setState(()=>_draft.userBubbleColor=v);_commit();}), const SizedBox(height:16),
            Text(_t('Color de la burbuja del personaje','Character bubble color'),style:const TextStyle(fontSize:13)), const SizedBox(height:6), BubbleColorRow(selected:_draft.aiBubbleColor,palette:kBubbleColorPalette,onPick:(v){setState(()=>_draft.aiBubbleColor=v);_commit();}), const SizedBox(height:16),
            _SliderRow(label:_t('Radio de las esquinas','Corner radius'),value:_draft.bubbleCornerRadius,min:0,max:24,divisions:24,valueLabel:'${_draft.bubbleCornerRadius.round()}',onChanged:(v)=>setState(()=>_draft.bubbleCornerRadius=v),onChangeEnd:_commit),
            _SliderRow(label:_t('Ancho del borde','Border width'),value:_draft.bubbleBorderWidth,min:0,max:3,divisions:6,valueLabel:_draft.bubbleBorderWidth.toStringAsFixed(1),onChanged:(v)=>setState(()=>_draft.bubbleBorderWidth=v),onChangeEnd:_commit),
            if(_draft.bubbleBorderWidth>0)...[Text(_t('Color del borde','Border color'),style:const TextStyle(fontSize:13)),const SizedBox(height:6),BubbleColorRow(selected:_draft.bubbleBorderColor,palette:kBubbleColorPalette,onPick:(v){setState(()=>_draft.bubbleBorderColor=v);_commit();}),const SizedBox(height:8)],
            _SliderRow(label:_t('Tamaño del texto de la burbuja','Bubble text size'),value:_draft.bubbleTextScale,min:.8,max:1.4,divisions:12,valueLabel:'${(_draft.bubbleTextScale*100).round()}%',onChanged:(v)=>setState(()=>_draft.bubbleTextScale=v),onChangeEnd:_commit),
            const SizedBox(height:8), Text(_t('Fuente de la burbuja','Bubble font'),style:TextStyle(color:EmberColors.textMid,fontSize:13)),const SizedBox(height:6), Wrap(spacing:8,children:[for(final opt in <(String,String?)>[(_t('Predeterminada','Default'),null),(_t('Serif','Serif'),'serif'),(_t('Mono','Mono'),'monospace')]) ChoiceChip(label:Text(opt.$1,style:TextStyle(fontFamily:opt.$2)),selected:_draft.bubbleFontFamily==opt.$2,selectedColor:EmberColors.primary.withValues(alpha:.25),onSelected:(_){setState(()=>_draft.bubbleFontFamily=opt.$2);_commit();})]), const SizedBox(height:8),
            _SliderRow(label:_t('Desenfoque del fondo','Background blur'),value:_draft.bubbleBlurSigma,min:0,max:12,divisions:12,valueLabel:'${_draft.bubbleBlurSigma.round()}',onChanged:(v)=>setState(()=>_draft.bubbleBlurSigma=v),onChangeEnd:_commit),
          ]))),
          Card(margin:const EdgeInsets.symmetric(vertical:6),child:Padding(padding:const EdgeInsets.fromLTRB(16,12,16,16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(_t('Fondo del chat','Chat background'),style:const TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:2),Text(_t('La imagen que aparece detrás de las burbujas de mensajes.','What image (if any) sits behind the message bubbles.'),style:TextStyle(color:EmberColors.textMid,fontSize:12)),const SizedBox(height:12),
            RadioGroup<ChatBackgroundSource>(groupValue:_draft.backgroundSource,onChanged:(v){if(v==null)return;setState(()=>_draft.backgroundSource=v);_commit();},child:Column(children:[for(final source in const [ChatBackgroundSource.characterAvatar,ChatBackgroundSource.personaAvatar,ChatBackgroundSource.custom,ChatBackgroundSource.dynamic,ChatBackgroundSource.none]) ListTile(contentPadding:EdgeInsets.zero,dense:true,leading:Radio<ChatBackgroundSource>(value:source,activeColor:EmberColors.primary),title:Text(_bgLabel(source)),subtitle:Text(_bgSubtitle(source),style:TextStyle(color:EmberColors.textMid,fontSize:11)),onTap:(){setState(()=>_draft.backgroundSource=source);_commit();})])),
            if(_draft.backgroundSource==ChatBackgroundSource.custom)...[const SizedBox(height:4),if(_draft.customBackgroundDataUrl!=null&&Lightbox.resolveImage(_draft.customBackgroundDataUrl)!=null) Padding(padding:const EdgeInsets.only(bottom:8),child:ClipRRect(borderRadius:BorderRadius.circular(8),child:Image(image:Lightbox.resolveImage(_draft.customBackgroundDataUrl)!,height:120,width:double.infinity,fit:BoxFit.cover,errorBuilder:(_,_,_)=>const SizedBox.shrink()))),Row(children:[ElevatedButton.icon(icon:const Icon(Icons.upload,size:16),label:Text(_draft.customBackgroundDataUrl==null?_t('Elegir imagen','Choose image'):_t('Reemplazar imagen','Replace image')),onPressed:_pickCustomBackground),const SizedBox(width:8),if(_draft.customBackgroundDataUrl!=null)TextButton.icon(icon:Icon(Icons.delete_outline,size:16,color:EmberColors.danger),label:Text(_t('Quitar','Clear'),style:TextStyle(color:EmberColors.danger)),onPressed:(){setState(()=>_draft.customBackgroundDataUrl=null);_commit();})])],
            if(_draft.backgroundSource!=ChatBackgroundSource.none)...[const SizedBox(height:16),Row(children:[Expanded(child:Text(_t('Opacidad del fondo','Background opacity'),style:const TextStyle(fontSize:13))),Text('${(_draft.backgroundOpacity*100).round()}%',style:TextStyle(color:EmberColors.textMid,fontFeatures:[FontFeature.tabularFigures()]))]),Slider(value:_draft.backgroundOpacity,min:0,max:1,divisions:20,activeColor:EmberColors.primary,onChanged:(v)=>setState(()=>_draft.backgroundOpacity=v),onChangeEnd:(_)=>_commit()),const SizedBox(height:16),Text(_t('Ajuste del fondo','Background fit'),style:const TextStyle(fontSize:13)),const SizedBox(height:2),Text(_t('Contener muestra la imagen completa; resulta especialmente útil en ventanas anchas con una imagen vertical.','Contain shows the whole image — most useful on wide windows with a portrait image.'),style:TextStyle(color:EmberColors.textMid,fontSize:11)),const SizedBox(height:8),_BgFitPicker(value:_draft.backgroundFit,onChanged:(f){setState(()=>_draft.backgroundFit=f);_commit();})],
          ]))),
          Card(margin:const EdgeInsets.symmetric(vertical:6),child:SwitchListTile(title:Text(_t('Ocultar razonamiento del modelo','Hide model reasoning'),style:const TextStyle(fontWeight:FontWeight.w600)),subtitle:Text(_t('Oculta bloques <think>…</think> de modelos de razonamiento (DeepSeek-R1, etc.) sin afectar la generación.','Hide <think>…</think> blocks from reasoning models (DeepSeek-R1 etc.) without affecting generation.'),style:TextStyle(color:EmberColors.textMid,fontSize:12)),value:_draft.hideReasoning,activeThumbColor:EmberColors.primary,onChanged:(v){setState(()=>_draft.hideReasoning=v);_commit();})),
        ],
      ),
    );
  }
}

class _BgFitPicker extends StatelessWidget {
  final ChatBackgroundFit value;
  final ValueChanged<ChatBackgroundFit> onChanged;
  const _BgFitPicker({required this.value,required this.onChanged});
  String _label(BuildContext context, ChatBackgroundFit f){final es=AppStrings.of(context).es;String t(String s,String e)=>es?s:e;switch(f){case ChatBackgroundFit.cover:return t('Cubrir','Cover');case ChatBackgroundFit.contain:return t('Contener','Contain');case ChatBackgroundFit.fitWidth:return t('Ajustar al ancho','Fit width');case ChatBackgroundFit.fill:return t('Estirar','Stretch');}}
  @override Widget build(BuildContext context)=>Wrap(spacing:8,children:[for(final f in ChatBackgroundFit.values)ChoiceChip(label:Text(_label(context,f)),selected:value==f,selectedColor:EmberColors.primary.withValues(alpha:.25),onSelected:(_)=>onChanged(f))]);
}

class _SliderRow extends StatelessWidget {
  final String label; final double value,min,max; final int divisions; final String valueLabel; final ValueChanged<double> onChanged; final VoidCallback onChangeEnd;
  const _SliderRow({required this.label,required this.value,required this.min,required this.max,required this.divisions,required this.valueLabel,required this.onChanged,required this.onChangeEnd});
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(label,style:const TextStyle(fontSize:13))),Text(valueLabel,style:TextStyle(color:EmberColors.textMid,fontFeatures:[FontFeature.tabularFigures()]))]),Slider(value:value.clamp(min,max),min:min,max:max,divisions:divisions,activeColor:EmberColors.primary,onChanged:onChanged,onChangeEnd:(_)=>onChangeEnd())]);
}
