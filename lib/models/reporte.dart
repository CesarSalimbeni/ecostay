import 'package:cloud_firestore/cloud_firestore.dart';
import 'gestion_reportes.dart'; 

class Reporte {
  final String id;
  final String objetoId;
  final String? publicacionId; 
  final String autorObjetoId;
  final String usuarioReportoId;
  final String motivo;
  final TipoObjeto tipo;
  final DateTime fechaReporte;

  Reporte({
    required this.id,
    required this.objetoId,
    this.publicacionId,
    required this.autorObjetoId,
    required this.usuarioReportoId,
    required this.motivo,
    required this.tipo,
    required this.fechaReporte,
  });

  factory Reporte.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Reporte(
      id: doc.id,
      objetoId: data['objetoId'] ?? '',
      publicacionId: data['publicacionId'],
      autorObjetoId: data['autorObjetoId'] ?? '',
      usuarioReportoId: data['usuarioReportoId'] ?? '',
      motivo: data['motivo'] ?? '',
      tipo: data['tipo'] == TipoObjeto.PUBLICACION.name 
          ? TipoObjeto.PUBLICACION 
          : TipoObjeto.CALIFICACION,
      fechaReporte: (data['fechaReporte'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
