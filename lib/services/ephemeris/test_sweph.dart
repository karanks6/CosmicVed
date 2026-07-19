import 'package:sweph/sweph.dart';

void main() async {
  try {
    await Sweph.init(epheAssets: ["packages/sweph/assets/ephe/seas_18.se1"]);
    double jd = Sweph.swe_julday(1996, 5, 27, 14.3, CalendarType.SE_GREG_CAL);
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI, 0.0, 0.0);
    
    final sunPos = Sweph.swe_calc_ut(jd, HeavenlyBody.SE_SUN, SwephFlag.SEFLG_SIDEREAL | SwephFlag.SEFLG_SPEED);
    print("Sun Lon: ${sunPos.longitude}");
  } catch (e) {
    print(e);
  }
}
