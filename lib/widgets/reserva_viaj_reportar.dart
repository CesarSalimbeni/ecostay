import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/reserva.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:ecostay/models/gestion_reportes.dart'; 

class DialogoReportar extends StatefulWidget {
  final Reserva? reservaActual;
  final String publicacionId;
  final String viajeroId;
  final VoidCallback onReporteEnviado;
  final String? calificacionId; 
  final String? autorCalificacionId;

  const DialogoReportar({
    super.key,
    this.reservaActual,
    required this.publicacionId,
    required this.viajeroId,
    required this.onReporteEnviado,
    this.calificacionId,
    this.autorCalificacionId,
  });

  @override
  State<DialogoReportar> createState() => _DialogoReportarState();
}

class _DialogoReportarState extends State<DialogoReportar> {
  bool _mostrarFormulario = false;
  final TextEditingController _motivoController = TextEditingController();
  bool _enviando = false;

  bool get _esReporteComentario => widget.calificacionId != null;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
      backgroundColor: ColorPalette.bg, title: Text(
        _mostrarFormulario 
            ? (_esReporteComentario ? 'Reportar Comentario' : 'Reportar Publicación')
            : 'Asistencia de Estadía',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Idiqlat'),
      ),
      content: SizedBox(width: 450,
        child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
          child: _mostrarFormulario ? _buildFormulario() : _buildAvisoReporte(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_mostrarFormulario ? 'Cancelar' : 'Cerrar', style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildAvisoReporte() {
    return Container(
      key: const ValueKey('AvisoReporte'), width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.report_problem_rounded, color: Colors.red.shade800, size: 50),
          const SizedBox(height: 12),
          Text(
            _esReporteComentario ? '¿Reportar un comentario ofensivo?' : '¿Inconvenientes con el alojamiento?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _esReporteComentario
                ? 'Si consideras que la reseña infringe las normas de la comunidad, puedes reportarla para la revisión del administrador.'
                : 'Si la propiedad no cumple con lo publicado o infringe las normas, puedes reportar esta publicación.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => setState(() => _mostrarFormulario = true),
            icon: const Icon(Icons.campaign_outlined),
            label: Text(
              _esReporteComentario ? 'Reportar Reseña' : 'Iniciar Reporte',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      key: const ValueKey('FormularioReporte'), width: double.infinity,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _esReporteComentario ? 'Escribe el motivo del reporte del comentario:' : 'Escribe el motivo del reporte:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),
          TextField(controller: _motivoController, maxLines: 5,
            decoration: InputDecoration(
              hintText: _esReporteComentario 
                  ? 'Explica por qué este comentario debería ser removido...'
                  : 'Describe claramente los motivos por los cuales estás reportando este alojamiento...',
              labelText: 'Motivo',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF216A44), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF216A44),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _enviando ? null : () async {
              final motivo = _motivoController.text.trim();
              if (motivo.isEmpty) return;
              
              setState(() => _enviando = true);
              
              try {
                final gestionPublicacion = GestionPublicacion();
                final gestionReportes = GestionReportes();
                
                final String viajeroId = widget.viajeroId;
                final String publicacionId = widget.publicacionId;

                final String? proveedorId = await gestionPublicacion.obtenerProveedor(publicacionId);
                
                if (proveedorId == null) {
                  throw Exception('No se pudo encontrar la información del anfitrión.');
                }

                if (_esReporteComentario) {
                  final String autorId = (widget.autorCalificacionId != null && widget.autorCalificacionId!.isNotEmpty)
                      ? widget.autorCalificacionId!
                      : proveedorId;

                  final String comentarioId = (widget.calificacionId != null && widget.calificacionId!.isNotEmpty)
                      ? widget.calificacionId!
                      : 'id_comentario_invalido';

                  await gestionReportes.reportarCalificacion(
                    objetoId: comentarioId,
                    publicacionId: publicacionId,
                    autorCalificacionId: autorId, 
                    usuarioReportoId: viajeroId,
                    motivo: motivo,
                  );
                } else {
                  await gestionReportes.reportarPublicacion(
                    objetoId: publicacionId,
                    autorPublicacionId: proveedorId,
                    usuarioReportoId: viajeroId,
                    motivo: motivo,
                  );
                }

                widget.onReporteEnviado(); 
                if (mounted) Navigator.pop(context);
              } catch (e) {
                setState(() => _enviando = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                );
              }
            },
            child: _enviando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Enviar Reporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}