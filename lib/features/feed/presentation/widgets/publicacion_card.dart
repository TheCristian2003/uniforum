import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/estilo_publicacion.dart';
import '../../../../core/utils/fecha_relativa.dart';
import '../../../../data/models/publicacion.dart';
import '../../../publicaciones/presentation/widgets/imagenes_adjuntas.dart';

/// Tarjeta reutilizable para mostrar una publicación en el feed o en un canal.
///
/// Sigue el diseño de las tarjetas de "Inicio (Feed)": cabecera con autor,
/// canal y tipo, contenido y una barra inferior con votos y comentarios.
class PublicacionCard extends StatelessWidget {
  const PublicacionCard({
    super.key,
    required this.publicacion,
    this.onTap,
    this.onTapAutor,
  });

  final Publicacion publicacion;
  final VoidCallback? onTap;

  /// Abre el perfil del autor. Solo aplica cuando la publicación no es anónima.
  final VoidCallback? onTapAutor;

  @override
  Widget build(BuildContext context) {
    final alias = publicacion.anonimo
        ? 'Anónimo'
        : (publicacion.autorAlias ?? 'Usuario');
    final tipo = estiloTipo(context, publicacion.tipoCodigo);
    final precio = publicacion.metadatos.precio;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.colors.outline.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Cabecera(
                  alias: alias,
                  anonimo: publicacion.anonimo,
                  avatarUrl: publicacion.autorAvatarUrl,
                  verificada: publicacion.autorVerificada,
                  canalNombre: publicacion.canalNombre,
                  creadoEn: publicacion.creadoEn,
                  tipo: tipo,
                  tipoNombre: publicacion.tipoNombre,
                  onTapAutor: publicacion.anonimo ? null : onTapAutor,
                ),
                const SizedBox(height: 12),
                if (publicacion.titulo != null) ...[
                  Text(
                    publicacion.titulo!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  publicacion.cuerpo,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.4),
                ),
                if (precio != null) ...[
                  const SizedBox(height: 8),
                  _Precio(
                    valor: precio,
                    moneda: publicacion.metadatos.moneda ?? 'COP',
                  ),
                ],
                if (publicacion.imagenes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ImagenesAdjuntas(urls: publicacion.imagenes, radio: 10),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: context.colors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _PillVotos(valor: publicacion.puntaje),
                      const Spacer(),
                      _AccionComentario(valor: publicacion.comentariosCount),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera: avatar y autor a la izquierda; canal junto al nombre, hora debajo
/// y la etiqueta del tipo de publicación arriba a la derecha.
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.alias,
    required this.anonimo,
    required this.avatarUrl,
    required this.verificada,
    required this.canalNombre,
    required this.creadoEn,
    required this.tipo,
    required this.tipoNombre,
    this.onTapAutor,
  });

  final String alias;
  final bool anonimo;
  final String? avatarUrl;
  final bool verificada;
  final String? canalNombre;
  final DateTime creadoEn;
  final EstiloTipo tipo;
  final String? tipoNombre;
  final VoidCallback? onTapAutor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTapAutor,
          behavior: HitTestBehavior.opaque,
          child: _Avatar(alias: alias, imagen: avatarUrl, anonimo: anonimo),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: onTapAutor,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        alias,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                  if (verificada) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 15,
                      color: context.colors.ugBlue,
                    ),
                  ],
                  if (canalNombre != null) ...[
                    const SizedBox(width: 6),
                    Flexible(child: _ChipCanal(texto: canalNombre!)),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                fechaRelativa(creadoEn),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (tipoNombre != null) ...[
          const SizedBox(width: 8),
          _EtiquetaTipo(tipo: tipo, texto: tipoNombre!),
        ],
      ],
    );
  }
}

/// Chip con el nombre del canal, a la derecha del nombre del autor.
class _ChipCanal extends StatelessWidget {
  const _ChipCanal({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.ugBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: context.colors.ugBlue,
        ),
      ),
    );
  }
}

/// Etiqueta del tipo de publicación, arriba a la derecha de la cabecera.
class _EtiquetaTipo extends StatelessWidget {
  const _EtiquetaTipo({required this.tipo, required this.texto});

  final EstiloTipo tipo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: fondoAcento(tipo.color),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tipo.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tipo.icono, size: 13, color: tipo.color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: tipo.color,
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.ugOcre.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.ugOcre.withValues(alpha: 0.5)),
      ),
      child: Text(
        '\$${numeroCorto(valor)} $moneda',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3D2A00),
        ),
      ),
    );
  }
}

/// Píldora con los dos botones de voto (arriba/abajo) y el puntaje en medio.
class _PillVotos extends StatelessWidget {
  const _PillVotos({required this.valor});

  final int valor;

  @override
  Widget build(BuildContext context) {
    final texto = valor > 0 ? '+$valor' : '$valor';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _IconoVoto(icono: Icons.arrow_upward),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ),
          const _IconoVoto(icono: Icons.arrow_downward),
        ],
      ),
    );
  }
}

class _IconoVoto extends StatelessWidget {
  const _IconoVoto({required this.icono});

  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(icono, size: 18, color: context.colors.onSurfaceVariant),
    );
  }
}

/// Acción de comentarios con su contador, alineada a la derecha.
class _AccionComentario extends StatelessWidget {
  const _AccionComentario({required this.valor});

  final int valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 18,
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(
          '$valor',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
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
      radius: 18,
      backgroundColor: context.colors.ugBlueLight,
      backgroundImage: tieneImagen ? NetworkImage(imagen!) : null,
      child: tieneImagen
          ? null
          : (anonimo
                ? Icon(Icons.person, color: context.colors.ugBlue)
                : Text(
                    alias.isNotEmpty ? alias[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.colors.ugBlue,
                    ),
                  )),
    );
  }
}
