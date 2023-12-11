import 'package:flutter/material.dart';
import 'package:login_test/utils.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  bool isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SizedBox(
      width: double.infinity,
      child: Container(
        // loginxe5 (21:408)
        width: double.infinity,
        decoration: BoxDecoration (
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(30*fem),
        ),
        child: ListView(
          children: [
            Container(
              // homeindicatorh5s (208:157)
              padding: EdgeInsets.fromLTRB(4*fem, 9*fem, 15.67*fem, 0*fem),
              width: double.infinity,
              height: 30*fem,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    // leftsideR1s (208:174)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 219.67*fem, 0*fem),
                    width: 54*fem,
                    height: 21*fem,
                    child: Image.asset(
                      'assets/ver02/images/left-side-9Xf.png',
                      width: 54*fem,
                      height: 21*fem,
                    ),
                  ),
                  Container(
                    // rightsideWp1 (208:158)
                    margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 0.33*fem),
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          // autogroup64sme9X (HnT7h4xU2ZYCdQdE4g64SM)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 5.03*fem, 0.33*fem),
                          width: 17*fem,
                          height: 20.33*fem,
                          child: Image.asset(
                            'assets/ver02/images/auto-group-64sm.png',
                            width: 17*fem,
                            height: 20.33*fem,
                          ),
                        ),
                        Container(
                          // wifiMZj (208:163)
                          margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 5.03*fem, 0.37*fem),
                          width: 15.27*fem,
                          height: 10.97*fem,
                          child: Image.asset(
                            'assets/ver02/images/wifi-TAq.png',
                            width: 15.27*fem,
                            height: 10.97*fem,
                          ),
                        ),
                        SizedBox(
                          // batteryU8Z (208:159)
                          width: 24.33*fem,
                          height: 11.33*fem,
                          child: Image.asset(
                            'assets/ver02/images/battery-kJM.png',
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
                // autogroupj9pwoRj (HnT6abotPPMqPryhXXj9Pw)
                padding: EdgeInsets.fromLTRB(25*fem, 98*fem, 25*fem, 156*fem),
                width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        // alphabookstorelogodarkverX6q (21:1251)
                        margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 50*fem),
                        width: 188*fem,
                        height: 174*fem,
                        child: Image.asset(
                          'assets/ver02/images/alpha-bookstorelogodark-ver-Qpy.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        // usernamefieldq7X (21:427)
                        margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 23.5 * fem),
                        padding: EdgeInsets.fromLTRB(18 * fem, 18 * fem, 18 * fem, 8 * fem),
                        width: double.infinity,
                        height: 58.5 * fem,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff8e8e93)),
                          color: const Color(0xffffffff),
                          borderRadius: BorderRadius.circular(5 * fem),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0a000000),
                              offset: Offset(0 * fem, 1 * fem),
                              blurRadius: 5 * fem,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          // autogroupqzmbhQd (HnT7CzvuPvD9gH4mxJqZMB)
                          width: double.infinity,
                          height: double.infinity,
                          child: Row(
                            children: [
                              Container(
                                // placeholderSND (21:429)
                                margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 15 * fem, 10 * fem),
                                child: Icon(
                                  Icons.person_outline, // You can use any icon that represents a username
                                  size: 16 * ffem,
                                  color: const Color(0x7f3c3c43),
                                ),
                              ),
                              Expanded(
                                child: Material(
                                  borderRadius: BorderRadius.circular(5 * fem),
                                  color: Colors.transparent, // Set the color to transparent
                                  child: TextField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      border: InputBorder.none,
                                      hintStyle: safeGoogleFont(
                                        'Inter',
                                        fontSize: 17 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5 * ffem / fem,
                                        letterSpacing: -0.4079999924 * fem,
                                        color: const Color(0x7f3c3c43),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _usernameController.clear(); // Clear the text in the TextField
                                },
                                child: SizedBox(
                                  width: 17 * fem,
                                  height: 17 * fem,
                                  child: Image.asset(
                                    'assets/ver02/images/sf-symbol-xmarkcirclefill-NQ9.png',
                                    width: 17 * fem,
                                    height: 17 * fem,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        // passwordfieldq7X (21:427)
                        margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 23.5 * fem),
                        padding: EdgeInsets.fromLTRB(18 * fem, 18 * fem, 18 * fem, 8 * fem),
                        width: double.infinity,
                        height: 58.5 * fem,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff8e8e93)),
                          color: const Color(0xffffffff),
                          borderRadius: BorderRadius.circular(5 * fem),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x0a000000),
                              offset: Offset(0 * fem, 1 * fem),
                              blurRadius: 5 * fem,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          // autogroupqzmbhQd (HnT7CzvuPvD9gH4mxJqZMB)
                          width: double.infinity,
                          height: double.infinity,
                          child: Row(
                            children: [
                              Container(
                                // placeholderSND (21:429)
                                margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 15 * fem, 10 * fem),
                                child: Icon(
                                  Icons.lock_outline, // You can use any icon that represents a password
                                  size: 16 * ffem,
                                  color: const Color(0x7f3c3c43),
                                ),
                              ),
                              Expanded(
                                child: Material(
                                  borderRadius: BorderRadius.circular(5 * fem),
                                  color: Colors.transparent, // Set the color to transparent
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: !isPasswordVisible, // Hide the password text
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      border: InputBorder.none,
                                      hintStyle: safeGoogleFont(
                                        'Inter',
                                        fontSize: 17 * ffem,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5 * ffem / fem,
                                        letterSpacing: -0.4079999924 * fem,
                                        color: const Color(0x7f3c3c43),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // Toggle the password visibility
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                                child: SizedBox(
                                  width: 19 * fem,
                                  height: 12.38 * fem,
                                  child: Image.asset(
                                    isPasswordVisible
                                        ? 'assets/ver02/images/password-not-visible-9-64.png' // Icon when password is visible
                                        : 'assets/ver02/images/bi-eye-fill-UbT.png', // Icon when password is hidden
                                    width: 19 * fem,
                                    height: 12.38 * fem,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        // loginbuttonuoX (21:417)
                        margin: EdgeInsets.fromLTRB(0*fem, 0*fem, 0*fem, 27*fem),
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
                                'Log In',
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
                        // signuplinkYrV (21:415)
                        margin: EdgeInsets.fromLTRB(28.5*fem, 0*fem, 28.5*fem, 0*fem),
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
                                    color: const Color(0xff8e8e93),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Don’t have an account yet? ',
                                    ),
                                    TextSpan(
                                      text: 'Sign up here',
                                      style: safeGoogleFont (
                                        'Inter',
                                        fontSize: 14*ffem,
                                        fontWeight: FontWeight.w700,
                                        height: 1.5714285714*ffem/fem,
                                        letterSpacing: -0.4079999924*fem,
                                        color: const Color(0xff8e8e93),
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