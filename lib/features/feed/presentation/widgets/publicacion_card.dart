import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/estilo_publicacion.dart';
import '../../../../core/utils/fecha_relativa.dart';
import '../../../../data/models/publicacion.dart';
import '../../../publicaciones/presentation/widgets/imagenes_adjuntas.dart';

/// Tarjeta reutilizable para mostrar una publicación en el feed o en un canal.
class PublicacionCard extends StatelessWidget {
  const PublicacionCard({super.key, required this.publicacion, this.onTap});

  final Publicacion publicacion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final alias = publicacion.anonimo
        ? 'Anónimo'
        : (publicacion.autorAlias ?? 'Usuario');
    final tipo = estiloTipo(publicacion.tipoCodigo);
    final categoriaColor = colorCategoria(publicacion.categoriaCodigo);
    final precio = publicacion.metadatos.precio;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(
                    alias: alias,
                    imagen: publicacion.anonimo
                        ? null
                        : publicacion.autorAvatarUrl,
                    anonimo: publicacion.anonimo,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                alias,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (publicacion.autorVerificada) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 15,
                                color: AppColors.ugBlue,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          [
                            if (publicacion.canalNombre != null)
                              publicacion.canalNombre!,
                            fechaRelativa(publicacion.creadoEn),
                          ].join(' · '),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconoTipo(tipo: tipo),
                ],
              ),
              const SizedBox(height: 12),
              if (publicacion.titulo != null || precio != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (publicacion.titulo != null)
                      Expanded(
                        child: Text(
                          publicacion.titulo!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    if (precio != null) ...[
                      if (publicacion.titulo != null) const SizedBox(width: 10),
                      _Precio(
                        valor: precio,
                        moneda: publicacion.metadatos.moneda ?? 'COP',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Text(
                publicacion.cuerpo,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.4),
              ),
              if (publicacion.imagenes.isNotEmpty) ...[
                const SizedBox(height: 10),
                ImagenesAdjuntas(urls: publicacion.imagenes, radio: 10),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (publicacion.categoriaNombre != null)
                    _Etiqueta(
                      texto: publicacion.categoriaNombre!,
                      color: categoriaColor,
                      fondo: fondoAcento(categoriaColor),
                    ),
                  if (publicacion.tipoNombre != null) ...[
                    const SizedBox(width: 6),
                    _Etiqueta(
                      texto: publicacion.tipoNombre!,
                      icono: tipo.icono,
                      color: tipo.color,
                      fondo: fondoAcento(tipo.color),
                    ),
                  ],
                  const Spacer(),
                  _Pildora(
                    icono: Icons.arrow_upward,
                    valor: publicacion.puntaje,
                  ),
                  const SizedBox(width: 6),
                  _Pildora(
                    icono: Icons.mode_comment_outlined,
                    valor: publicacion.comentariosCount,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
        ),
    );
  }
}

/// Precio destacado de las publicaciones de venta.
class _Precio extends StatelessWidget {
  const _Precio({required this.valor, required this.moneda});

  final num valor;
  final String moneda;

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${numeroCorto(valor)} $moneda',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.ugFlamenco,
      ),
    );
  }
}

/// Píldora con icono y valor, usada para puntaje y comentarios.
class _Pildora extends StatelessWidget {
  const _Pildora({required this.icono, required this.valor});

  final IconData icono;
  final int valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 15,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            '$valor',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icono del tipo de publicación, con su color distintivo.
class _IconoTipo extends StatelessWidget {
  const _IconoTipo({required this.tipo});

  final EstiloTipo tipo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: fondoAcento(tipo.color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(tipo.icono, size: 18, color: tipo.color),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.alias, this.imagen, this.anonimo = false});

  final String alias;
  final String? imagen;
  final bool anonimo;

  @override
  Widget build(BuildContext context) {
    final tieneImagen = imagen != null && imagen!.isNotEmpty;
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.ugBlueLight,
      backgroundImage: tieneImagen ? NetworkImage(imagen!) : null,
      child: tieneImagen
          ? null
          : (anonimo
                ? const Icon(Icons.person, color: AppColors.ugBlue)
                : Text(
                    alias.isNotEmpty ? alias[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ugBlue,
                    ),
                  )),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.texto,
    required this.color,
    required this.fondo,
    this.icono,
  });

  final String texto;
  final Color color;
  final Color fondo;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
