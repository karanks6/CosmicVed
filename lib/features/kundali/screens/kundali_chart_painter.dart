import 'package:flutter/material.dart';
import '../../../theme/color_scheme.dart';
import '../../../models/models.dart';

class KundaliChartPainter extends CustomPainter {
  final Kundali kundali;
  final String style;

  KundaliChartPainter({required this.kundali, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    if (style == 'south') {
      _paintSouthIndian(canvas, size);
    } else {
      _paintNorthIndian(canvas, size);
    }
  }

  void _paintNorthIndian(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Draw the grid lines
    final linePaint = Paint()
      ..color = CosmicColors.gold.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Outer square
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), linePaint);
    
    // Diagonals
    canvas.drawLine(const Offset(0, 0), Offset(w, h), linePaint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), linePaint);
    
    // Inner diamond
    canvas.drawLine(Offset(w / 2, 0), Offset(w, h / 2), linePaint);
    canvas.drawLine(Offset(w, h / 2), Offset(w / 2, h), linePaint);
    canvas.drawLine(Offset(w / 2, h), Offset(0, h / 2), linePaint);
    canvas.drawLine(Offset(0, h / 2), Offset(w / 2, 0), linePaint);

    // Text positions for the 12 houses (centered in each triangle)
    final housePositions = [
      Offset(w / 2, h / 4),        // House 1 (top center)
      Offset(w / 4, h / 8),        // House 2 (top left upper)
      Offset(w / 8, h / 4),        // House 3 (top left lower)
      Offset(w / 4, h / 2),        // House 4 (left center)
      Offset(w / 8, h * 3 / 4),    // House 5 (bottom left upper)
      Offset(w / 4, h * 7 / 8),    // House 6 (bottom left lower)
      Offset(w / 2, h * 3 / 4),    // House 7 (bottom center)
      Offset(w * 3 / 4, h * 7 / 8),// House 8 (bottom right lower)
      Offset(w * 7 / 8, h * 3 / 4),// House 9 (bottom right upper)
      Offset(w * 3 / 4, h / 2),    // House 10 (right center)
      Offset(w * 7 / 8, h / 4),    // House 11 (top right lower)
      Offset(w * 3 / 4, h / 8),    // House 12 (top right upper)
    ];

    for (int i = 0; i < 12; i++) {
      final rashiInHouse = kundali.houseRashis[i];
      final planetsHere = kundali.planetsInHouse(i + 1);
      final center = housePositions[i];

      // Rashi number
      _drawText(
        canvas,
        '${rashiInHouse + 1}',
        Offset(center.dx, center.dy - 10),
        const TextStyle(
          color: CosmicColors.textLow,
          fontSize: 12,
          fontFamily: 'Inter',
        ),
      );

      // Planets
      if (planetsHere.isNotEmpty) {
        final planetStr = planetsHere.map(_planetAbbr).join(' ');
        _drawText(
          canvas,
          planetStr,
          Offset(center.dx, center.dy + 8),
          const TextStyle(
            color: CosmicColors.gold,
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }
  }

  void _paintSouthIndian(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Draw the grid lines
    final linePaint = Paint()
      ..color = CosmicColors.gold.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cellW = w / 4;
    final cellH = h / 4;

    // Outer boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), linePaint);
    
    // Vertical inner lines
    canvas.drawLine(Offset(cellW, 0), Offset(cellW, h), linePaint);
    canvas.drawLine(Offset(cellW * 2, 0), Offset(cellW * 2, cellH), linePaint);
    canvas.drawLine(Offset(cellW * 2, cellH * 3), Offset(cellW * 2, h), linePaint);
    canvas.drawLine(Offset(cellW * 3, 0), Offset(cellW * 3, h), linePaint);
    
    // Horizontal inner lines
    canvas.drawLine(Offset(0, cellH), Offset(w, cellH), linePaint);
    canvas.drawLine(Offset(0, cellH * 2), Offset(cellW, cellH * 2), linePaint);
    canvas.drawLine(Offset(cellW * 3, cellH * 2), Offset(w, cellH * 2), linePaint);
    canvas.drawLine(Offset(0, cellH * 3), Offset(w, cellH * 3), linePaint);

    // Inner empty box border
    canvas.drawRect(Rect.fromLTWH(cellW, cellH, cellW * 2, cellH * 2), linePaint);

    // South Indian maps signs to fixed boxes (Aries is top left second box)
    // 0: Aries, 1: Taurus, 2: Gemini, 3: Cancer, 4: Leo, 5: Virgo, 6: Libra, 7: Scorpio, 8: Sagittarius, 9: Capricorn, 10: Aquarius, 11: Pisces
    final signPositions = [
      Offset(cellW * 1.5, cellH * 0.5), // Aries
      Offset(cellW * 2.5, cellH * 0.5), // Taurus
      Offset(cellW * 3.5, cellH * 0.5), // Gemini
      Offset(cellW * 3.5, cellH * 1.5), // Cancer
      Offset(cellW * 3.5, cellH * 2.5), // Leo
      Offset(cellW * 3.5, cellH * 3.5), // Virgo
      Offset(cellW * 2.5, cellH * 3.5), // Libra
      Offset(cellW * 1.5, cellH * 3.5), // Scorpio
      Offset(cellW * 0.5, cellH * 3.5), // Sagittarius
      Offset(cellW * 0.5, cellH * 2.5), // Capricorn
      Offset(cellW * 0.5, cellH * 1.5), // Aquarius
      Offset(cellW * 0.5, cellH * 0.5), // Pisces
    ];

    for (int signIndex = 0; signIndex < 12; signIndex++) {
      final center = signPositions[signIndex];
      final rashiText = _rashiName(signIndex);
      
      _drawText(
        canvas,
        rashiText,
        Offset(center.dx, center.dy - 12),
        const TextStyle(
          color: CosmicColors.textLow,
          fontSize: 10,
          fontFamily: 'Inter',
        ),
      );

      // Check which house falls in this sign and draw Lagna marker if it's the 1st house
      int houseNum = -1;
      for (int i = 0; i < 12; i++) {
        if (kundali.houseRashis[i] == signIndex) {
          houseNum = i + 1;
          break;
        }
      }

      if (houseNum == 1) {
        _drawText(
          canvas,
          'Lagna',
          Offset(center.dx, center.dy - 24),
          TextStyle(
            color: CosmicColors.gold.withValues(alpha: 0.8),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
      }

      // Find planets in this house
      final planetsHere = kundali.planetsInHouse(houseNum);
      if (planetsHere.isNotEmpty) {
        final planetStr = planetsHere.map(_planetAbbr).join('\n');
        _drawText(
          canvas,
          planetStr,
          Offset(center.dx, center.dy + 8),
          const TextStyle(
            color: CosmicColors.gold,
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.layout();
    tp.paint(canvas, Offset(position.dx - tp.width / 2, position.dy - tp.height / 2));
  }

  String _planetAbbr(PlanetPosition p) {
    const abbrs = {
      'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
      'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa',
      'Rahu': 'Ra', 'Ketu': 'Ke',
    };
    return '${abbrs[p.name] ?? p.name[0]}${p.isRetrograde ? 'R' : ''}';
  }
  
  String _rashiName(int index) {
    const names = ['Ar', 'Ta', 'Ge', 'Ca', 'Le', 'Vi', 'Li', 'Sc', 'Sg', 'Cp', 'Aq', 'Pi'];
    return names[index % 12];
  }

  @override
  bool shouldRepaint(KundaliChartPainter old) => old.style != style;
}
