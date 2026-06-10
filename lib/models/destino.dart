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

List<Destino> destinosDePrueba = [
  Destino(
    nombre: 'Los Roques',
    ubicacion: 'Dependencias Federales',
    calificacion: 4.9,
    precio: 45.0,
    imageUrl:
        'https://images.unsplash.com/photo-1590523277543-a94d2e4eb00b?auto=format&fit=crop&w=600&q=80',
  ),
  Destino(
    nombre: 'Salto Ángel',
    ubicacion: 'Canaima',
    calificacion: 5.0,
    precio: 120.0,
    imageUrl:
        'https://images.unsplash.com/photo-1433086966358-54859d0ed716?auto=format&fit=crop&w=600&q=80',
  ),
  Destino(
    nombre: 'Isla Margarita',
    ubicacion: 'Nueva Esparta',
    calificacion: 4.5,
    precio: 25.0,
    imageUrl:
        'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=600&q=80',
  ),
  Destino(
    nombre: 'Pico Bolívar',
    ubicacion: 'Mérida',
    calificacion: 4.8,
    precio: 35.0,
    imageUrl:
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=600&q=80',
  ),
  Destino(
    nombre: 'Cayo Sombrero',
    ubicacion: 'Falcón',
    calificacion: 4.7,
    precio: 40.0,
    imageUrl:
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
  ),
];
