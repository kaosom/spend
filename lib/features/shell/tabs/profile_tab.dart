import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/storage/storage_service.dart';
import '../../accounts/accounts_controller.dart';
import '../../transactions/transactions_controller.dart';
import '../../settings/settings_controller.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final exportResult = await StorageService.exportAllData();
      Get.back(); // close loading

      if (exportResult.isFailure) {
        Get.snackbar(
          'Error',
          'No se pudo exportar los datos.',
          backgroundColor: AvidTokens.accentError,
          colorText: Colors.white,
        );
        return;
      }

      final jsonString = exportResult.data!;
      final dateStr = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final fileName = 'avid_spend_backup_$dateStr.json';

      // Pick save location via file_picker
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar respaldo de datos',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile == null) {
        // User canceled the picker
        return;
      }

      final file = File(outputFile);
      await file.writeAsString(jsonString);

      Get.snackbar(
        'Exportación Completa',
        'Datos guardados en:\n$outputFile',
        backgroundColor: AvidTokens.accentSuccess,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Error inesperado: $e',
        backgroundColor: AvidTokens.accentError,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // Pick file to import
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecciona tu archivo de respaldo',
      );

      if (result == null || result.files.single.path == null) {
        // User canceled
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      // Ask for confirmation
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AvidTokens.backgroundSecondary,
          title: Text('¿Importar respaldo?', style: AvidTokens.heading4),
          content: Text(
            'Esto sobreescribirá todas tus transacciones, cuentas y configuraciones actuales. Esta acción no se puede deshacer.',
            style: AvidTokens.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancelar',
                style: AvidTokens.labelMedium.copyWith(
                  color: AvidTokens.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AvidTokens.accentError,
                foregroundColor: Colors.white,
              ),
              child: const Text('Importar y Sobreescribir'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Import the data via StorageService
      final importResult = await StorageService.importData(jsonString);

      if (importResult.isFailure) {
        Get.back(); // clode loading
        Get.snackbar(
          'Error Importando',
          importResult.error!.message,
          backgroundColor: AvidTokens.accentError,
          colorText: Colors.white,
        );
        return;
      }

      // Reload all controllers to apply the new state!
      await Get.find<SettingsController>().loadSettings();
      await Get.find<AccountsController>().loadAccounts();
      await Get.find<TransactionsController>().loadTransactions();

      Get.back(); // close loading

      Get.snackbar(
        'Importación Exitosa',
        'Tus datos han sido restaurados correctamente.',
        backgroundColor: AvidTokens.accentSuccess,
        colorText: Colors.white,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Error inesperado importando: $e',
        backgroundColor: AvidTokens.accentError,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AvidTokens.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AvidTokens.backgroundPrimary,
          elevation: 0,
          title: Text('Perfil', style: AvidTokens.heading2),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AvidTokens.space4),
          children: [
            // User Header Placeholder
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AvidTokens.backgroundSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AvidTokens.borderPrimary,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AvidTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AvidTokens.space3),
                  Text('Angel Sosa', style: AvidTokens.heading4),
                  Text(
                    'analyst@avid.io',
                    style: AvidTokens.bodyMedium.copyWith(
                      color: AvidTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AvidTokens.space8),

            // Profile Settings block
            Text('Respaldo de Datos', style: AvidTokens.labelLarge),
            const SizedBox(height: AvidTokens.space3),

            _buildSettingCard(
              icon: Icons.upload_file,
              title: 'Exportar Datos',
              subtitle: 'Guarda un archivo .json con tus registros',
              onTap: () => _exportData(context),
            ),

            const SizedBox(height: AvidTokens.space2),

            _buildSettingCard(
              icon: Icons.download_rounded,
              title: 'Importar Datos',
              subtitle: 'Restaura tus registros desde un archivo .json',
              isDestructive: true,
              onTap: () => _importData(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AvidTokens.accentError
        : AvidTokens.accentPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AvidTokens.space4),
        decoration: BoxDecoration(
          color: AvidTokens.backgroundSecondary,
          borderRadius: BorderRadius.circular(AvidTokens.radiusMedium),
          border: Border.all(
            color: AvidTokens.borderPrimary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AvidTokens.space2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AvidTokens.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AvidTokens.heading4),
                  Text(
                    subtitle,
                    style: AvidTokens.bodySmall.copyWith(
                      color: AvidTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AvidTokens.textTertiary),
          ],
        ),
      ),
    );
  }
}
