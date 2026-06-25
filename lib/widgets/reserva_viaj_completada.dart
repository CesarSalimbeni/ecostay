import 'package:ecostay/pantallas/estilo.dart';
import 'package:flutter/material.dart';
import 'package:ecostay/models/reserva.dart';
import 'package:ecostay/models/gestion_publicacion.dart';
import 'package:ecostay/models/gestion_reservacion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DialogoComentario extends StatefulWidget {
  final Reserva reservaActual;
  final VoidCallback onResenaEnviada;

  const DialogoComentario({
    super.key, 
    required this.reservaActual,
    required this.onResenaEnviada,
  });

  @override
  State<DialogoComentario> createState() => _DialogoComentarioState();
}

class _DialogoComentarioState extends State<DialogoComentario> {
  bool _mostrarFormulario = false; 
  int _puntajeSeleccionado = 5;    
  final TextEditingController _comentarioController = TextEditingController();
  bool _enviando = false;
  
  bool _esEdicion = false;
  String? _calificacionIdExistente;
  bool _cargandoDatosExistentes = true;
  String _publicacionId = '';

  @override
  void initState() {
    super.initState();
    _verificarResenaExistente();
  }

  Future<void> _verificarResenaExistente() async {
    try {
      final gestionReservacion = GestionReservacion();
      final (_, _, publicacionId) = await gestionReservacion.obtenerInformacion(widget.reservaActual.id);
      _publicacionId = publicacionId;
      
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('publications')
          .doc(publicacionId)
          .collection('ratings')
          .where('reservacionId', isEqualTo: widget.reservaActual.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty && mounted) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        
        setState(() {
          _esEdicion = true;
          _calificacionIdExistente = doc.id;
          _puntajeSeleccionado = (data['puntaje'] as num).toInt();
          _comentarioController.text = data['comentario'] ?? '';
          _cargandoDatosExistentes = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _cargandoDatosExistentes = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error al verificar reseña existente: $e');
      if (mounted) {
        setState(() {
          _cargandoDatosExistentes = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String tituloDialogo = 'Estadía Confirmada';
    if (_mostrarFormulario) {
      tituloDialogo = _esEdicion ? 'Editar Reseña' : 'Escribir Reseña';
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
      backgroundColor: ColorPalette.bg, 
      title: Text( 
        tituloDialogo, 
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Idiqlat'),
      ),
      content: SizedBox(width: 450,
        child: _cargandoDatosExistentes 
            ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: Color(0xFF216A44))))
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _mostrarFormulario ? _buildFormulario() : _buildAvisoConfirmacion(),
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

  Widget _buildAvisoConfirmacion() {
    return Container(key: const ValueKey('Aviso'), width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50, 
        borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green.shade300, width: 1.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF216A44), size: 50),
          const SizedBox(height: 12),
          const Text('¡Tu estadía ya está asegurada y pagada!', textAlign: TextAlign.center, style: TextStyle(
            color: Color(0xFF216A44), fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Monto pagado: \$${widget.reservaActual.total.toStringAsFixed(2)}.', style: TextStyle(
            color: Colors.grey.shade700, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() => _mostrarFormulario = true); 
            },
            icon: Icon(_esEdicion ? Icons.edit_note : Icons.rate_review),
            label: Text(
              _esEdicion ? 'Modificar mi Reseña' : 'Dejar una Reseña', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(key: const ValueKey('Formulario'), 
      width: double.infinity, color: ColorPalette.bg,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _esEdicion ? 'Actualiza tu experiencia:' : '¿Cómo fue tu experiencia?', 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
          ),
          const SizedBox(height: 10),
          
          // Selector de Estrellas Dinámico
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _puntajeSeleccionado ? Icons.star : Icons.star_border, color: Colors.amber, size: 36,
                ),
                onPressed: () {
                  setState(() => _puntajeSeleccionado = index + 1);
                },
              );
            }),
          ),
          const SizedBox(height: 15),
          
          TextField(
            controller: _comentarioController, maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe tu opinión aquí...',
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
              backgroundColor: const Color(0xFF216A44), foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _enviando ? null : _procesarEnvioResena,
            child: _enviando 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _esEdicion ? 'Guardar Cambios' : 'Enviar Reseña', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarEnvioResena() async {
    if (_comentarioController.text.trim().isEmpty) return;
    
    setState(() => _enviando = true);
    
    try {
      final gestionCalificacion = GestionCalificacion();
      
      if (_esEdicion) {
        await gestionCalificacion.editarCalificacion(
          _publicacionId,
          _calificacionIdExistente!,
          {
            'comentario': _comentarioController.text.trim(),
            'puntaje': _puntajeSeleccionado.toDouble(),
            'fechaModificacion': FieldValue.serverTimestamp(),
          },
        );
        
        await gestionCalificacion.calcularCalificacionPromedio(_publicacionId);
      } else {
        final gestionReservacion = GestionReservacion();
        final (_, viajeroId, publicacionId) = await gestionReservacion.obtenerInformacion(widget.reservaActual.id);

        String nombreRealUsuario = 'Huésped Ecostay';
        try {
          final docUsuario = await FirebaseFirestore.instance.collection('users').doc(viajeroId).get();
          if (docUsuario.exists && docUsuario.data() != null) {
            nombreRealUsuario = docUsuario.data()!['nombre'] ?? 'Huésped Ecostay';
          }
        } catch (e) {
          debugPrint('No se pudo obtener el nombre del usuario de Firestore, usando valor predeterminado: $e');
        }

        await gestionCalificacion.agregarCalificacion(
          publicacionId: publicacionId, 
          viajeroId: viajeroId,
          reservacionId: widget.reservaActual.id,
          comentario: _comentarioController.text.trim(),
          puntaje: _puntajeSeleccionado.toDouble(),
          nombreUsuario: nombreRealUsuario,
        );
      }

      widget.onResenaEnviada(); 
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la reseña: $e')),
      );
    }
  }
}