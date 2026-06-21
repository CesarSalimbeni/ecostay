import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  
  // Función principal que genera el documento y abre el menú de impresión
  Future<void> generarVoucher({
    required String idReserva,
    required String nombreAnfitrion,
    required String idViajero,
    required double monto,
    required String tituloPublicacion,
  }) async {
    final pdf = pw.Document();

    // Fecha actual formateada de forma simple
    final fechaActual = DateTime.now().toString().substring(0, 19);

    // Diseño del documento PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ENCABEZADO
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "COMPROBANTE DE RESERVA",
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "ÉXITO",
                      style: pw.TextStyle(
                        fontSize: 14, 
                        fontWeight: pw.FontWeight.bold, 
                        color: PdfColors.green
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),

                // DETALLES DEL COMPROBANTE
                pw.Text("Detalles de la Transacción:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                
                _filaDetalle("ID Reserva:", idReserva),
                _filaDetalle("Fecha y Hora:", fechaActual),
                _filaDetalle("ID Estudiante:", idViajero),
                _filaDetalle("Método de Pago:", "PayPal (Simulado)"),
                
                pw.SizedBox(height: 20),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 20),

                // DETALLES DEL SERVICIO / DESTINO
                pw.Text("Descripción del Servicio:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _filaDetalle("Destino/Concepto:", tituloPublicacion),
                _filaDetalle("Nombre Anfitrion:", nombreAnfitrion),

                pw.SizedBox(height: 30),

                // CUADRO DEL TOTAL
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text("Total Pagado: ", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                          "\$${monto.toStringAsFixed(2)} USD", 
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                // PIE DE PÁGINA
                pw.Center(
                  child: pw.Text(
                    "Gracias por tu confianza. Este es un comprobante digital automatizado.",
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Muestra la ventana nativa para Imprimir o Guardar como PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Comprobante_${idReserva}.pdf',
    );
  }

  // Widget auxiliar para estructurar las filas de datos alineadas
  pw.Widget _filaDetalle(String titulo, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(titulo, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(child: pw.Text(valor)),
        ],
      ),
    );
  }
}