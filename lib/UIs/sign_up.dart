import 'package:flutter/material.dart';
import 'package:login_test/utils.dart';

class Scene extends StatelessWidget {
  const Scene({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SizedBox(
      width: double.infinity,
      child: Container(
        // signupS6D (21:351)
        width: double.infinity,
        decoration: BoxDecoration (
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(30*fem),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // homeindicatorYuw (21:388)
              padding: EdgeInsets.fromLTRB(4*fem, 9*fem, 15.67*fem, 0*fem),
              width: double.infinity,
              height: 30*fem,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    // leftsideTn1 (21:405)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 219.67*fem, 0*fem),
                    width: 54*fem,
                    height: 21*fem,
                    child: Image.asset(
                      'assets/ver02/images/left-side-tu7.png',
                      width: 54*fem,
                      height: 21*fem,
                    ),
                  ),
                  Container(
                    // rightsiden3b (21:389)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 0.33*fem),
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          // autogroupsvah7Lm (HnT6Lh3PzkcqJv7iMfSVaH)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 5.03*fem, 0.33*fem),
                          width: 17*fem,
                          height: 20.33*fem,
                          child: Image.asset(
                            'assets/ver02/images/auto-group-svah.png',
                            width: 17*fem,
                            height: 20.33*fem,
                          ),
                        ),
                        Container(
                          // wifipFB (21:394)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 5.03*fem, 0.37*fem),
                          width: 15.27*fem,
                          height: 10.97*fem,
                          child: Image.asset(
                            'assets/ver02/images/wifi-xbB.png',
                            width: 15.27*fem,
                            height: 10.97*fem,
                          ),
                        ),
                        SizedBox(
                          // batteryjN9 (21:390)
                          width: 24.33*fem,
                          height: 11.33*fem,
                          child: Image.asset(
                            'assets/ver02/images/battery-XbX.png',
                            width: 24.33*fem,
                            height: 11.33*fem,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // autogroupoqg1TJ9 (HnT5Wt5j7MUzjwXSTLoQG1)
              padding: EdgeInsets.fromLTRB(25*fem, 54*fem, 25*fem, 110*fem),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    // alphabookstorelogodarkverAyF (21:1252)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 52*fem),
                    width: 124*fem,
                    height: 115*fem,
                    child: Image.asset(
                      'assets/ver02/images/alpha-bookstorelogodark-ver-P9B.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    // fieldsgAu (21:363)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 35.5*fem),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          // namefieldbof (21:381)
                          width: double.infinity,
                          height: 58.5*fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle22Yiu (21:382)
                                left: 0*fem,
                                top: 0*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 310*fem,
                                    height: 58*fem,
                                    child: Container(
                                      decoration: BoxDecoration (
                                        borderRadius: BorderRadius.circular(5*fem),
                                        border: Border.all(color: const Color(0xff8e8e93)),
                                        color: const Color(0xffffffff),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x0a000000),
                                            offset: Offset(0*fem, 1*fem),
                                            blurRadius: 5*fem,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // placeholderbhB (21:383)
                                left: 29*fem,
                                top: 18*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 124*fem,
                                    height: 22*fem,
                                    child: Text(
                                      'Trần Quang Minh',
                                      style: safeGoogleFont (
                                        'Inter',
                                        fontSize: 16*ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.375*ffem/fem,
                                        letterSpacing: -0.4079999924*fem,
                                        color: const Color(0x7f3c3c43),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // sfsymbolxmarkcirclefillrd7 (21:384)
                                left: 274.9470214844*fem,
                                top: 21*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 17*fem,
                                    height: 17*fem,
                                    child: Image.asset(
                                      'assets/ver02/images/sf-symbol-xmarkcirclefill-twT.png',
                                      width: 17*fem,
                                      height: 17*fem,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 24.5*fem,
                        ),
                        SizedBox(
                          // usernamefieldLYH (21:376)
                          width: double.infinity,
                          height: 58.5*fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle2261f (21:377)
                                left: 0*fem,
                                top: 0*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 310*fem,
                                    height: 58*fem,
                                    child: Container(
                                      decoration: BoxDecoration (
                                        borderRadius: BorderRadius.circular(5*fem),
                                        border: Border.all(color: const Color(0xff8e8e93)),
                                        color: const Color(0xffffffff),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x0a000000),
                                            offset: Offset(0*fem, 1*fem),
                                            blurRadius: 5*fem,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // placeholderaBj (21:378)
                                left: 29*fem,
                                top: 18*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 55*fem,
                                    height: 22*fem,
                                    child: Text(
                                      '3ciadgr',
                                      style: safeGoogleFont (
                                        'Inter',
                                        fontSize: 16*ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.375*ffem/fem,
                                        letterSpacing: -0.4079999924*fem,
                                        color: const Color(0x7f3c3c43),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // vectorfU5 (21:380)
                                left: 275*fem,
                                top: 21*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 17*fem,
                                    height: 17*fem,
                                    child: Image.asset(
                                      'assets/ver02/images/vector-doX.png',
                                      width: 17*fem,
                                      height: 17*fem,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 24.5*fem,
                        ),
                        SizedBox(
                          // emailfieldyDs (21:371)
                          width: double.infinity,
                          height: 58.5*fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle227L5 (21:372)
                                left: 0*fem,
                                top: 0*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 310*fem,
                                    height: 58*fem,
                                    child: Container(
                                      decoration: BoxDecoration (
                                        borderRadius: BorderRadius.circular(5*fem),
                                        border: Border.all(color: const Color(0xff8e8e93)),
                                        color: const Color(0xffffffff),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x0a000000),
                                            offset: Offset(0*fem, 1*fem),
                                            blurRadius: 5*fem,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // placeholderC6d (21:373)
                                left: 29*fem,
                                top: 18*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 125*fem,
                                    height: 22*fem,
                                    child: Text(
                                      'trcrlx@gmail.com',
                                      style: safeGoogleFont (
                                        'Inter',
                                        fontSize: 16*ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.375*ffem/fem,
                                        letterSpacing: -0.4079999924*fem,
                                        color: const Color(0x7f3c3c43),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // sfsymbolxmarkcirclefillJ9f (21:374)
                                left: 274.9470214844*fem,
                                top: 21*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 17*fem,
                                    height: 17*fem,
                                    child: Image.asset(
                                      'assets/ver02/images/sf-symbol-xmarkcirclefill-uMj.png',
                                      width: 17*fem,
                                      height: 17*fem,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 24.5*fem,
                        ),
                        SizedBox(
                          // passwordfieldBz9 (21:364)
                          width: double.infinity,
                          height: 58.5*fem,
                          child: Stack(
                            children: [
                              Positioned(
                                // rectangle22Ls3 (21:365)
                                left: 0*fem,
                                top: 0*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 310*fem,
                                    height: 58*fem,
                                    child: Container(
                                      decoration: BoxDecoration (
                                        borderRadius: BorderRadius.circular(5*fem),
                                        border: Border.all(color: const Color(0xff8e8e93)),
                                        color: const Color(0xffffffff),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x0a000000),
                                            offset: Offset(0*fem, 1*fem),
                                            blurRadius: 5*fem,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // placeholdercZf (21:366)
                                left: 29*fem,
                                top: 18*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 84*fem,
                                    height: 22*fem,
                                    child: Text(
                                      '***********',
                                      style: safeGoogleFont (
                                        'Inter',
                                        fontSize: 16*ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.375*ffem/fem,
                                        letterSpacing: -0.4079999924*fem,
                                        color: const Color(0x7f3c3c43),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                // bieyefillJxH (21:368)
                                left: 274*fem,
                                top: 22.8125*fem,
                                child: Align(
                                  child: SizedBox(
                                    width: 19*fem,
                                    height: 12.38*fem,
                                    child: Image.asset(
                                      'assets/ver02/images/bi-eye-fill-YuX.png',
                                      width: 19*fem,
                                      height: 12.38*fem,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // createaccountbuttonDJZ (21:360)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 24*fem),
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom (
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 50*fem,
                        decoration: BoxDecoration (
                          color: const Color(0xff404040),
                          borderRadius: BorderRadius.circular(10*fem),
                        ),
                        child: Center(
                          child: Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: safeGoogleFont (
                              'Inter',
                              fontSize: 18*ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.2125*ffem/fem,
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    // linkFFF (21:358)
                    margin: EdgeInsets.fromLTRB(41*fem, 0*fem, 34*fem, 0*fem),
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom (
                        padding: EdgeInsets.zero,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 22*fem,
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              style: safeGoogleFont (
                                'Inter',
                                fontSize: 14*ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.5714285714*ffem/fem,
                                letterSpacing: -0.4079999924*fem,
                                color: const Color(0xff828282),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Already have an account? ',
                                ),
                                TextSpan(
                                  text: 'Log in here',
                                  style: safeGoogleFont (
                                    'Inter',
                                    fontSize: 14*ffem,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5714285714*ffem/fem,
                                    letterSpacing: -0.4079999924*fem,
                                    color: const Color(0xff828282),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
          );
  }
}