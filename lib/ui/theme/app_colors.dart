import 'package:flutter/material.dart';

const Color brandOrange     = Color(0xFFFF6B35);
const Color brandOrangeDark = Color(0xFFE85D2B); // novo — substitui o pink no gradiente
const Color brandOrangePink = Color(0xFFFF4F7B); // mantém para compatibilidade
const Color brandOrangeLight = Color(0xFFFFF7ED); // era #FFF3EC, agora warm off-white
const Color surfaceGray     = Color(0xFFF5F2EE); // era #F5F5F5, levemente mais quente
const Color textMedium      = Color(0xFF64748B); // era #888888 (contraste baixo), agora 4.5:1
const Color textLight       = Color(0xFF94A3B8); // novo — para textos secundários menores
const Color badgeGreen      = Color(0xFF059669); // era #4CAF50, mais rico

const LinearGradient brandGradient = LinearGradient(
  colors: [brandOrange, brandOrangeDark],
);
