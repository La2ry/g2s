import 'package:g2s/mock/g2s_user.dart';
import 'package:g2s/page/login_page.dart';
import 'package:g2s/page/password_reset_page.dart';
import 'package:g2s/page/project_explorer_page.dart';
import 'package:g2s/page/register_page.dart';
import 'package:g2s/page/stock_management_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter route = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const ProjectExplorerPage(),
      redirect: (context, state) {
        G2SUser? g2sUser = context.read<G2SUser?>();
        if (g2sUser is G2SUser) {
          return null;
        }
        return '/signin';
      },
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/password_reset',
      builder: (context, state) => const PasswordResetPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/stock_management/:projectID',
      builder: (context, state) => StockManagementPage(
        projectID: state.pathParameters['projectID']!,
      ),
    ),
  ],
);
