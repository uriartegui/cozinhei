import 'package:flutter/material.dart';

// ── Design System Palette ──────────────────────────────────────────────────────

// Primary — laranja principal (CTA, activos, destaques)
const Color brandPrimary      = Color(0xFFFF6B44);
const Color brandPrimaryDark  = Color(0xFFAE310E);
const Color brandPrimaryLight = Color(0xFFFFF7ED);

// Secondary — terracota (badges, labels, tags)
const Color brandSecondary      = Color(0xFFB0624D);
const Color brandSecondaryLight = Color(0xFFFAEDE9);

// Tertiary — teal (geladeira, nutrição, destaques alternativos)
const Color brandTertiary      = Color(0xFF00ABB1);
const Color brandTertiaryLight = Color(0xFFE6F7F8);

// Neutral — textos e superfícies
const Color neutralDark       = Color(0xFF1C1C1E);  // texto principal
const Color neutralMedium     = Color(0xFF64748B);  // texto secundário
const Color neutralLight      = Color(0xFF94A3B8);  // placeholder / hint
const Color neutralSurface    = Color(0xFFF5F2EE);  // fundo de cards
const Color neutralBackground = Color(0xFFFFF7ED);  // fundo de página

// Gradient principal
const LinearGradient brandGradient = LinearGradient(
  colors: [brandPrimaryDark, brandPrimary],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ── Aliases legados (não quebram código existente) ─────────────────────────────
const Color brandOrange      = brandPrimary;
const Color brandOrangeDark  = brandPrimaryDark;
const Color brandOrangeLight = brandPrimaryLight;
const Color surfaceGray      = neutralSurface;
const Color textMedium       = neutralMedium;
const Color textLight        = neutralLight;
const Color badgeGreen       = Color(0xFF059669);
