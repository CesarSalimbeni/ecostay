import 'usuario.dart';
import 'reserva.dart';
import 'estadoreserva.dart';
import 'publicacion.dart';
import 'estadistica.dart';

// Esta clase calcula las estadisticas que se muestran en el
// Dashboard del Administrador.
// recibe listas ya armadas y calcula, sin tocar Firebase todavia
class GestionEstadisticas {

  // Cuenta cuantos usuarios estan activos (no suspendidos)
  int contarUsuariosActivos(List<Usuario> usuarios) {
    int activos = 0;

    for (int i = 0; i < usuarios.length; i++) {
      if (usuarios[i].suspendido == false) {
        activos = activos + 1;
      }
    }

    return activos;
  }

  // Suma el volumen total de dinero en reservas confirmadas o completadas
  // (estas son las transacciones que ya se le pagaron a los prestadores)
  double calcularVolumenReservas(List<Reserva> reservas) {
    double total = 0;

    for (int i = 0; i < reservas.length; i++) {
      bool cuenta = reservas[i].estado == EstadoReserva.CONFIRMADA ||
          reservas[i].estado == EstadoReserva.COMPLETADA;

      if (cuenta) {
        total = total + reservas[i].total;
      }
    }

    return total;
  }

  // Cuenta cuantas publicaciones siguen activas, es decir,
  // que todavia les queda cupo disponible (cuposActual menor a cuposMax)
  int contarPublicacionesActivas(List<Publicacion> publicaciones) {
    int activas = 0;

    for (int i = 0; i < publicaciones.length; i++) {
      if (publicaciones[i].cuposActual < publicaciones[i].cuposMax) {
        activas = activas + 1;
      }
    }

    return activas;
  }

  // Cuenta cuantas reservas se han hecho en total
  // (sin importar el estado, es el total de reservas creadas)
  int contarReservasHechas(List<Reserva> reservas) {
    return reservas.length;
  }

  // Funcion principal: arma las 4 tarjetas del dashboard del admin
  List<Estadistica> generarEstadisticasGlobales({
    required List<Usuario> usuarios,
    required List<Reserva> reservas,
    required List<Publicacion> publicaciones,
  }) {
    List<Estadistica> resultado = [];

    int usuariosActivos = contarUsuariosActivos(usuarios);
    double volumenReservas = calcularVolumenReservas(reservas);
    int publicacionesActivas = contarPublicacionesActivas(publicaciones);
    int reservasHechas = contarReservasHechas(reservas);

    resultado.add(Estadistica(nombre: "Usuarios Activos", valor: usuariosActivos.toDouble()));
    resultado.add(Estadistica(nombre: "Volumen de Reservas", valor: volumenReservas));
    resultado.add(Estadistica(nombre: "Publicaciones Activas", valor: publicacionesActivas.toDouble()));
    resultado.add(Estadistica(nombre: "Reservas Hechas", valor: reservasHechas.toDouble()));

    return resultado;
  }
}