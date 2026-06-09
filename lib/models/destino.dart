class Destino {
  final String nombre;
  final String ubicacion;
  final double calificacion;
  final double precio;
  final String imageUrl;

  Destino({
    required this.nombre,
    required this.ubicacion,
    required this.calificacion,
    required this.precio,
    required this.imageUrl,
  });
}

// Lista de datos falsos para poder probar la barra de búsqueda después
List<Destino> destinosDePrueba = [
  Destino(
    nombre: 'Los Roques',
    ubicacion: 'Dependencias Federales',
    calificacion: 4.9,
    precio: 45.0,
    imageUrl: 'https://placehold.co/381x447',
  ),
  Destino(
    nombre: 'Salto Ángel',
    ubicacion: 'Canaima',
    calificacion: 5.0,
    precio: 120.0,
    imageUrl: 'https://placehold.co/381x447',
  ),
  Destino(
    nombre: 'Isla Margarita',
    ubicacion: 'Nueva Esparta',
    calificacion: 4.7,
    precio: 30.0,
    imageUrl: 'https://placehold.co/381x447',
  ),
];
