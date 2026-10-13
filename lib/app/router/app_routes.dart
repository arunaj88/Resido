import 'package:flutter/material.dart';
import 'package:resido/core/widgets/coming_soon_view.dart';
import 'package:resido/features/auth/presentation/screens/create_account_screen.dart';
import 'package:resido/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:resido/features/auth/presentation/screens/recovery_feedback_screen.dart';
import 'package:resido/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:resido/features/auth/presentation/screens/welcome_screen.dart';
import 'package:resido/features/home/presentation/screens/home_shell.dart';
import 'package:resido/features/maintenance/data/maintenance_mock_data.dart';
import 'package:resido/features/maintenance/presentation/screens/maintenance_form_screen.dart';
import 'package:resido/features/maintenance/presentation/screens/maintenance_list_screen.dart';
import 'package:resido/features/maintenance/presentation/screens/request_details_screen.dart';
import 'package:resido/features/maintenance/presentation/screens/update_status_screen.dart';
import 'package:resido/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:resido/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:resido/features/profile/presentation/screens/settings_screen.dart';
import 'package:resido/features/properties/data/property_mock_data.dart';
import 'package:resido/features/properties/presentation/screens/add_property_screen.dart';
import 'package:resido/features/properties/presentation/screens/edit_property_screen.dart';
import 'package:resido/features/properties/presentation/screens/property_details_screen.dart';
import 'package:resido/features/properties/presentation/screens/unit_form_screen.dart';
import 'package:resido/features/properties/presentation/screens/unit_list_screen.dart';
import 'package:resido/features/rent/data/rent_mock_data.dart';
import 'package:resido/features/rent/presentation/screens/partial_payment_screen.dart';
import 'package:resido/features/rent/presentation/screens/receipt_screen.dart';
import 'package:resido/features/rent/presentation/screens/record_payment_screen.dart';
import 'package:resido/features/rent/presentation/screens/rent_details_screen.dart';
import 'package:resido/features/splash/presentation/screens/splash_screen.dart';
import 'package:resido/features/tenants/data/tenant_mock_data.dart';
import 'package:resido/features/tenants/presentation/screens/add_tenant_screen.dart';
import 'package:resido/features/tenants/presentation/screens/assign_tenant_screen.dart';
import 'package:resido/features/tenants/presentation/screens/edit_tenant_screen.dart';
import 'package:resido/features/tenants/presentation/screens/tenancy_details_screen.dart';
import 'package:resido/features/tenants/presentation/screens/tenant_details_screen.dart';

/// Named routes for the app. Plain [Navigator] routing is enough for the
/// UI-only phase; arguments are passed through [RouteSettings.arguments].
abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const createAccount = '/create-account';
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot-password';

  /// Expects a [RecoveryFeedbackState] argument (defaults to link sent).
  static const recoveryFeedback = '/recovery-feedback';

  /// Signed-in shell with the bottom navigation. Optional [HomeArgs].
  static const home = '/home';
  static const notifications = '/notifications';

  /// Temporary destination for later batches. Expects [ComingSoonArgs].
  static const comingSoon = '/coming-soon';

  // Property management. Screens that show a property expect the selected
  // [MockProperty] as the route argument.
  static const addProperty = '/properties/add';
  static const propertyDetails = '/properties/details';
  static const editProperty = '/properties/edit';
  static const unitList = '/properties/units';

  /// Expects [UnitFormArgs] (no unit = Add Unit mode).
  static const unitForm = '/properties/units/form';

  // Tenant management. Tenant screens expect the selected [MockTenant].
  static const addTenant = '/tenants/add';
  static const tenantDetails = '/tenants/details';
  static const editTenant = '/tenants/edit';

  /// Optional [AssignTenantArgs].
  static const assignTenant = '/tenants/assign';

  /// Expects [TenancyDetailsArgs].
  static const tenancyDetails = '/tenants/tenancy';

  // Rent management. These screens expect the selected [RentRecord].
  static const rentDetails = '/rent/details';
  static const recordPayment = '/rent/record-payment';
  static const partialPayment = '/rent/partial-payment';

  /// Expects [ReceiptArgs].
  static const receipt = '/rent/receipt';

  // Maintenance. Details and Update Status expect a [MaintenanceRequest];
  // the form takes one optionally (prefilled = Edit Request).
  static const maintenance = '/maintenance';
  static const maintenanceForm = '/maintenance/create';
  static const maintenanceDetails = '/maintenance/details';
  static const updateStatus = '/maintenance/status';

  // Profile & Settings.
  static const editProfile = '/profile/edit';
  static const settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(settings, const SplashScreen());
      case welcome:
        // Splash hands over with a soft fade instead of a platform slide.
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => const WelcomeScreen(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      case createAccount:
        return _page(settings, const CreateAccountScreen());
      case signIn:
        return _page(
          settings,
          SignInScreen(newAccount: settings.arguments == true),
        );
      case forgotPassword:
        return _page(settings, const ForgotPasswordScreen());
      case recoveryFeedback:
        final state = settings.arguments is RecoveryFeedbackState
            ? settings.arguments! as RecoveryFeedbackState
            : RecoveryFeedbackState.linkSent;
        return _page(settings, RecoveryFeedbackScreen(initialState: state));
      case home:
        final args = settings.arguments is HomeArgs
            ? settings.arguments! as HomeArgs
            : const HomeArgs();
        return _page(settings, HomeShell(args: args));
      case notifications:
        return _page(settings, const NotificationsScreen());
      case comingSoon:
        final args = settings.arguments is ComingSoonArgs
            ? settings.arguments! as ComingSoonArgs
            : const ComingSoonArgs('Coming soon', Icons.construction);
        return _page(settings, ComingSoonScreen(args: args));
      case addProperty:
        return _page(settings, const AddPropertyScreen());
      case propertyDetails:
        return _page(
          settings,
          PropertyDetailsScreen(property: _property(settings)),
        );
      case editProperty:
        return _page(
          settings,
          EditPropertyScreen(property: _property(settings)),
        );
      case unitList:
        return _page(settings, UnitListScreen(property: _property(settings)));
      case unitForm:
        final args = settings.arguments is UnitFormArgs
            ? settings.arguments! as UnitFormArgs
            : const UnitFormArgs(property: PropertyMockData.palmGrove);
        return _page(settings, UnitFormScreen(args: args));
      case addTenant:
        return _page(settings, const AddTenantScreen());
      case tenantDetails:
        return _page(settings, TenantDetailsScreen(tenant: _tenant(settings)));
      case editTenant:
        return _page(settings, EditTenantScreen(tenant: _tenant(settings)));
      case assignTenant:
        final args = settings.arguments is AssignTenantArgs
            ? settings.arguments! as AssignTenantArgs
            : const AssignTenantArgs();
        return _page(settings, AssignTenantScreen(args: args));
      case tenancyDetails:
        final args = settings.arguments is TenancyDetailsArgs
            ? settings.arguments! as TenancyDetailsArgs
            : TenancyDetailsArgs(
                tenant: TenantMockData.suresh,
                tenancy: TenantMockData.suresh.tenancy!,
              );
        return _page(settings, TenancyDetailsScreen(args: args));
      case rentDetails:
        return _page(settings, RentDetailsScreen(record: _rent(settings)));
      case recordPayment:
        return _page(settings, RecordPaymentScreen(record: _rent(settings)));
      case partialPayment:
        return _page(settings, PartialPaymentScreen(record: _rent(settings)));
      case receipt:
        final args = settings.arguments is ReceiptArgs
            ? settings.arguments! as ReceiptArgs
            : ReceiptArgs(payment: RentMockData.payments.first);
        return _page(settings, ReceiptScreen(args: args));
      case maintenance:
        return _page(settings, const MaintenanceListScreen());
      case maintenanceForm:
        return _page(
          settings,
          MaintenanceFormScreen(
            request: settings.arguments is MaintenanceRequest
                ? settings.arguments! as MaintenanceRequest
                : null,
          ),
        );
      case maintenanceDetails:
        return _page(
          settings,
          RequestDetailsScreen(request: _maintenance(settings)),
        );
      case updateStatus:
        return _page(
          settings,
          UpdateStatusScreen(request: _maintenance(settings)),
        );
      case editProfile:
        return _page(settings, const EditProfileScreen());
      case AppRoutes.settings:
        return _page(settings, const SettingsScreen());
      default:
        return _page(settings, const WelcomeScreen());
    }
  }

  static MockProperty _property(RouteSettings settings) =>
      settings.arguments is MockProperty
      ? settings.arguments! as MockProperty
      : PropertyMockData.palmGrove;

  static MockTenant _tenant(RouteSettings settings) =>
      settings.arguments is MockTenant
      ? settings.arguments! as MockTenant
      : TenantMockData.suresh;

  static RentRecord _rent(RouteSettings settings) =>
      settings.arguments is RentRecord
      ? settings.arguments! as RentRecord
      : RentMockData.ananya;

  static MaintenanceRequest _maintenance(RouteSettings settings) =>
      settings.arguments is MaintenanceRequest
      ? settings.arguments! as MaintenanceRequest
      : MaintenanceMockData.seepage;

  static MaterialPageRoute<void> _page(RouteSettings settings, Widget child) =>
      MaterialPageRoute<void>(settings: settings, builder: (_) => child);

  /// Shows Sign In directly above Welcome, so switching between the auth
  /// screens never stacks duplicate pages. [newAccount] marks the visit as
  /// coming from Create Account, so Sign In lands on the Empty Dashboard.
  static void openSignIn(BuildContext context, {bool newAccount = false}) =>
      _openAboveWelcome(context, signIn, arguments: newAccount);

  /// Shows Create Account directly above Welcome.
  static void openCreateAccount(BuildContext context) =>
      _openAboveWelcome(context, createAccount);

  static void _openAboveWelcome(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (r) => r.settings.name == welcome,
      arguments: arguments,
    );
  }

  /// Opens a clearly labelled placeholder for a later-batch screen.
  static void openComingSoon(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    Navigator.of(
      context,
    ).pushNamed(comingSoon, arguments: ComingSoonArgs(title, icon));
  }

  static void openPropertyDetails(
    BuildContext context,
    MockProperty property,
  ) => Navigator.of(context).pushNamed(propertyDetails, arguments: property);

  static void openEditProperty(BuildContext context, MockProperty property) =>
      Navigator.of(context).pushNamed(editProperty, arguments: property);

  static void openUnitList(BuildContext context, MockProperty property) =>
      Navigator.of(context).pushNamed(unitList, arguments: property);

  /// Opens the unit form in Add mode, or Edit mode when [unit] is given.
  static void openUnitForm(
    BuildContext context,
    MockProperty property, {
    MockUnit? unit,
  }) => Navigator.of(context).pushNamed(
    unitForm,
    arguments: UnitFormArgs(property: property, unit: unit),
  );

  static void openTenantDetails(BuildContext context, MockTenant tenant) =>
      Navigator.of(context).pushNamed(tenantDetails, arguments: tenant);

  static void openEditTenant(BuildContext context, MockTenant tenant) =>
      Navigator.of(context).pushNamed(editTenant, arguments: tenant);

  static void openAssignTenant(
    BuildContext context, {
    MockTenant? tenant,
    MockProperty? property,
    MockUnit? unit,
  }) => Navigator.of(context).pushNamed(
    assignTenant,
    arguments: AssignTenantArgs(tenant: tenant, property: property, unit: unit),
  );

  /// Opens the tenant's current tenancy, or [tenancy] when given.
  static void openTenancyDetails(
    BuildContext context,
    MockTenant tenant, {
    MockTenancy? tenancy,
  }) {
    final t = tenancy ?? tenant.tenancy;
    if (t == null) return;
    Navigator.of(context).pushNamed(
      tenancyDetails,
      arguments: TenancyDetailsArgs(tenant: tenant, tenancy: t),
    );
  }

  static void openRentDetails(BuildContext context, RentRecord record) =>
      Navigator.of(context).pushNamed(rentDetails, arguments: record);

  static void openRecordPayment(BuildContext context, RentRecord record) =>
      Navigator.of(context).pushNamed(recordPayment, arguments: record);

  static void openPartialPayment(BuildContext context, RentRecord record) =>
      Navigator.of(context).pushNamed(partialPayment, arguments: record);

  static void openReceipt(BuildContext context, RentPayment payment) =>
      Navigator.of(
        context,
      ).pushNamed(receipt, arguments: ReceiptArgs(payment: payment));

  /// Opens Create Request, or Edit Request when [request] is given.
  static void openMaintenanceForm(
    BuildContext context, {
    MaintenanceRequest? request,
  }) => Navigator.of(context).pushNamed(maintenanceForm, arguments: request);

  static void openMaintenanceDetails(
    BuildContext context,
    MaintenanceRequest request,
  ) => Navigator.of(context).pushNamed(maintenanceDetails, arguments: request);

  static void openUpdateStatus(
    BuildContext context,
    MaintenanceRequest request,
  ) => Navigator.of(context).pushNamed(updateStatus, arguments: request);
}
