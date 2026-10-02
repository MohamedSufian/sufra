import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/maps/app_map.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/context_x.dart';
import '../../core/widgets/sufra_logo.dart';
import 'address.dart';
import 'addresses_controller.dart';

/// Step 2 of adding an address: label, landmark and phone. Pops with the saved address.
class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, required this.draft});

  final AddressDraft draft;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _landmark = TextEditingController(text: widget.draft.editing?.landmark);
  late final _details = TextEditingController(text: widget.draft.editing?.details);
  late final _phone = TextEditingController(text: widget.draft.editing?.phone);
  late var _label = widget.draft.editing?.label ?? AddressLabel.home;
  var _triedToSave = false;

  @override
  void dispose() {
    _landmark.dispose();
    _details.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) {
      setState(() => _triedToSave = true);
      return;
    }
    final d = widget.draft;
    final address = SavedAddress(
      id: d.editing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      label: _label,
      latitude: d.latitude,
      longitude: d.longitude,
      area: d.area,
      landmark: _landmark.text.trim(),
      details: _details.text.trim(),
      phone: PhoneNumbers.normalize(_phone.text),
    );
    ref.read(addressesProvider.notifier).save(address);
    context.pop(address);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = widget.draft;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addressDetailsTitle)),
      body: Form(
        key: _form,
        autovalidateMode: _triedToSave ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AppMap(latitude: d.latitude, longitude: d.longitude, zoom: 16.5, interactive: false),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 36),
                      child: SufraLogo(size: 40, color: AppColors.ember, cutColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.ember),
                const SizedBox(width: 6),
                Expanded(child: Text(d.area.resolve(context.locale), style: context.text.titleMedium)),
                TextButton(onPressed: () => context.pop(), child: Text(l10n.changeLocation)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final (label, text, icon) in [
                  (AddressLabel.home, l10n.labelHome, Icons.home_rounded),
                  (AddressLabel.work, l10n.labelWork, Icons.work_rounded),
                  (AddressLabel.other, l10n.labelOther, Icons.place_rounded),
                ])
                  ChoiceChip(
                    label: Text(text),
                    avatar: Icon(icon, size: 18, color: _label == label ? Colors.white : context.sufra.muted),
                    selected: _label == label,
                    showCheckmark: false,
                    selectedColor: AppColors.ember,
                    labelStyle: context.text.labelLarge?.copyWith(color: _label == label ? Colors.white : null),
                    onSelected: (_) => setState(() => _label = label),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _landmark,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.landmarkLabel,
                hintText: l10n.landmarkHint,
                prefixIcon: const Icon(Icons.flag_rounded),
              ),
              validator: (v) => (v ?? '').trim().length < 3 ? l10n.landmarkRequired : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _details,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: '${l10n.detailsLabel} (${l10n.optional})',
                prefixIcon: const Icon(Icons.apartment_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: InputDecoration(
                labelText: l10n.phoneLabel,
                hintText: '059 123 4567',
                hintTextDirection: TextDirection.ltr,
                prefixIcon: const Icon(Icons.phone_rounded),
              ),
              validator: (v) => PhoneNumbers.isValidMobile(v ?? '') ? null : l10n.phoneInvalid,
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: _save, child: Text(l10n.saveAddress)),
          ],
        ),
      ),
    );
  }
}
