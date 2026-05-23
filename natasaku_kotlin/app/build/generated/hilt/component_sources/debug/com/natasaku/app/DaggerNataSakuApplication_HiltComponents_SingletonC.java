package com.natasaku.app;

import android.app.Activity;
import android.app.Service;
import android.view.View;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.SavedStateHandle;
import androidx.lifecycle.ViewModel;
import com.natasaku.app.data.datastore.UserPreferenceDataStore;
import com.natasaku.app.data.export.BackupRestoreService;
import com.natasaku.app.data.export.MonthlyReportExporters;
import com.natasaku.app.data.local.dao.BackupRestoreDao;
import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao;
import com.natasaku.app.data.local.dao.ExpenseTransactionDao;
import com.natasaku.app.data.local.dao.FixedExpenseDao;
import com.natasaku.app.data.local.dao.IncomeSourceDao;
import com.natasaku.app.data.local.dao.SavingAllocationDao;
import com.natasaku.app.data.local.dao.SavingTargetDao;
import com.natasaku.app.data.local.database.NataSakuDatabase;
import com.natasaku.app.di.AppModule_ProvideBackupRestoreDaoFactory;
import com.natasaku.app.di.AppModule_ProvideBackupRestoreServiceFactory;
import com.natasaku.app.di.AppModule_ProvideBudgetCalculatorFactory;
import com.natasaku.app.di.AppModule_ProvideBudgetPeriodDaoFactory;
import com.natasaku.app.di.AppModule_ProvideCompleteSetupUseCaseFactory;
import com.natasaku.app.di.AppModule_ProvideDailyBudgetCalculatorFactory;
import com.natasaku.app.di.AppModule_ProvideDailyBudgetSnapshotDaoFactory;
import com.natasaku.app.di.AppModule_ProvideDatabaseFactory;
import com.natasaku.app.di.AppModule_ProvideExpenseTransactionDaoFactory;
import com.natasaku.app.di.AppModule_ProvideFixedExpenseDaoFactory;
import com.natasaku.app.di.AppModule_ProvideIncomeSourceDaoFactory;
import com.natasaku.app.di.AppModule_ProvideLeftoverAllocationCalculatorFactory;
import com.natasaku.app.di.AppModule_ProvideMonthlyReportCalculatorFactory;
import com.natasaku.app.di.AppModule_ProvideMonthlyReportExportersFactory;
import com.natasaku.app.di.AppModule_ProvideOverbudgetCalculatorFactory;
import com.natasaku.app.di.AppModule_ProvideReminderSchedulerFactory;
import com.natasaku.app.di.AppModule_ProvideSavingAllocationDaoFactory;
import com.natasaku.app.di.AppModule_ProvideSavingTargetDaoFactory;
import com.natasaku.app.di.AppModule_ProvideSettingsRepositoryFactory;
import com.natasaku.app.di.AppModule_ProvideUserPreferenceDataStoreFactory;
import com.natasaku.app.domain.repository.SettingsRepository;
import com.natasaku.app.domain.usecase.CompleteSetupUseCase;
import com.natasaku.app.presentation.screen.budget.BudgetViewModel;
import com.natasaku.app.presentation.screen.budget.BudgetViewModel_HiltModules;
import com.natasaku.app.presentation.screen.home.HomeViewModel;
import com.natasaku.app.presentation.screen.home.HomeViewModel_HiltModules;
import com.natasaku.app.presentation.screen.report.MonthlyReportViewModel;
import com.natasaku.app.presentation.screen.report.MonthlyReportViewModel_HiltModules;
import com.natasaku.app.presentation.screen.saving.SavingViewModel;
import com.natasaku.app.presentation.screen.saving.SavingViewModel_HiltModules;
import com.natasaku.app.presentation.screen.settings.SettingsViewModel;
import com.natasaku.app.presentation.screen.settings.SettingsViewModel_HiltModules;
import com.natasaku.app.presentation.screen.setup.SetupViewModel;
import com.natasaku.app.presentation.screen.setup.SetupViewModel_HiltModules;
import com.natasaku.app.presentation.screen.splash.SplashViewModel;
import com.natasaku.app.presentation.screen.splash.SplashViewModel_HiltModules;
import com.natasaku.app.presentation.screen.transaction.TransactionHistoryViewModel;
import com.natasaku.app.presentation.screen.transaction.TransactionHistoryViewModel_HiltModules;
import com.natasaku.app.reminder.ReminderScheduler;
import dagger.hilt.android.ActivityRetainedLifecycle;
import dagger.hilt.android.ViewModelLifecycle;
import dagger.hilt.android.internal.builders.ActivityComponentBuilder;
import dagger.hilt.android.internal.builders.ActivityRetainedComponentBuilder;
import dagger.hilt.android.internal.builders.FragmentComponentBuilder;
import dagger.hilt.android.internal.builders.ServiceComponentBuilder;
import dagger.hilt.android.internal.builders.ViewComponentBuilder;
import dagger.hilt.android.internal.builders.ViewModelComponentBuilder;
import dagger.hilt.android.internal.builders.ViewWithFragmentComponentBuilder;
import dagger.hilt.android.internal.lifecycle.DefaultViewModelFactories;
import dagger.hilt.android.internal.lifecycle.DefaultViewModelFactories_InternalFactoryFactory_Factory;
import dagger.hilt.android.internal.managers.ActivityRetainedComponentManager_LifecycleModule_ProvideActivityRetainedLifecycleFactory;
import dagger.hilt.android.internal.managers.SavedStateHandleHolder;
import dagger.hilt.android.internal.modules.ApplicationContextModule;
import dagger.hilt.android.internal.modules.ApplicationContextModule_ProvideContextFactory;
import dagger.internal.DaggerGenerated;
import dagger.internal.DoubleCheck;
import dagger.internal.IdentifierNameString;
import dagger.internal.KeepFieldType;
import dagger.internal.LazyClassKeyMap;
import dagger.internal.MapBuilder;
import dagger.internal.Preconditions;
import dagger.internal.Provider;
import java.util.Collections;
import java.util.Map;
import java.util.Set;
import javax.annotation.processing.Generated;

@DaggerGenerated
@Generated(
    value = "dagger.internal.codegen.ComponentProcessor",
    comments = "https://dagger.dev"
)
@SuppressWarnings({
    "unchecked",
    "rawtypes",
    "KotlinInternal",
    "KotlinInternalInJava",
    "cast",
    "deprecation"
})
public final class DaggerNataSakuApplication_HiltComponents_SingletonC {
  private DaggerNataSakuApplication_HiltComponents_SingletonC() {
  }

  public static Builder builder() {
    return new Builder();
  }

  public static final class Builder {
    private ApplicationContextModule applicationContextModule;

    private Builder() {
    }

    public Builder applicationContextModule(ApplicationContextModule applicationContextModule) {
      this.applicationContextModule = Preconditions.checkNotNull(applicationContextModule);
      return this;
    }

    public NataSakuApplication_HiltComponents.SingletonC build() {
      Preconditions.checkBuilderRequirement(applicationContextModule, ApplicationContextModule.class);
      return new SingletonCImpl(applicationContextModule);
    }
  }

  private static final class ActivityRetainedCBuilder implements NataSakuApplication_HiltComponents.ActivityRetainedC.Builder {
    private final SingletonCImpl singletonCImpl;

    private SavedStateHandleHolder savedStateHandleHolder;

    private ActivityRetainedCBuilder(SingletonCImpl singletonCImpl) {
      this.singletonCImpl = singletonCImpl;
    }

    @Override
    public ActivityRetainedCBuilder savedStateHandleHolder(
        SavedStateHandleHolder savedStateHandleHolder) {
      this.savedStateHandleHolder = Preconditions.checkNotNull(savedStateHandleHolder);
      return this;
    }

    @Override
    public NataSakuApplication_HiltComponents.ActivityRetainedC build() {
      Preconditions.checkBuilderRequirement(savedStateHandleHolder, SavedStateHandleHolder.class);
      return new ActivityRetainedCImpl(singletonCImpl, savedStateHandleHolder);
    }
  }

  private static final class ActivityCBuilder implements NataSakuApplication_HiltComponents.ActivityC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private Activity activity;

    private ActivityCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
    }

    @Override
    public ActivityCBuilder activity(Activity activity) {
      this.activity = Preconditions.checkNotNull(activity);
      return this;
    }

    @Override
    public NataSakuApplication_HiltComponents.ActivityC build() {
      Preconditions.checkBuilderRequirement(activity, Activity.class);
      return new ActivityCImpl(singletonCImpl, activityRetainedCImpl, activity);
    }
  }

  private static final class FragmentCBuilder implements NataSakuApplication_HiltComponents.FragmentC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private Fragment fragment;

    private FragmentCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
    }

    @Override
    public FragmentCBuilder fragment(Fragment fragment) {
      this.fragment = Preconditions.checkNotNull(fragment);
      return this;
    }

    @Override
    public NataSakuApplication_HiltComponents.FragmentC build() {
      Preconditions.checkBuilderRequirement(fragment, Fragment.class);
      return new FragmentCImpl(singletonCImpl, activityRetainedCImpl, activityCImpl, fragment);
    }
  }

  private static final class ViewWithFragmentCBuilder implements NataSakuApplication_HiltComponents.ViewWithFragmentC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final FragmentCImpl fragmentCImpl;

    private View view;

    private ViewWithFragmentCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl,
        FragmentCImpl fragmentCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
      this.fragmentCImpl = fragmentCImpl;
    }

    @Override
    public ViewWithFragmentCBuilder view(View view) {
      this.view = Preconditions.checkNotNull(view);
      return this;
    }

    @Override
    public NataSakuApplication_HiltComponents.ViewWithFragmentC build() {
      Preconditions.checkBuilderRequirement(view, View.class);
      return new ViewWithFragmentCImpl(singletonCImpl, activityRetainedCImpl, activityCImpl, fragmentCImpl, view);
    }
  }

  private static final class ViewCBuilder implements NataSakuApplication_HiltComponents.ViewC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private View view;

    private ViewCBuilder(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
        ActivityCImpl activityCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
    }

    @Override
    public ViewCBuilder view(View view) {
      this.view = Preconditions.checkNotNull(view);
      return this;
    }

    @Override
    public NataSakuApplication_HiltComponents.ViewC build() {
      Preconditions.checkBuilderRequirement(view, View.class);
      return new ViewCImpl(singletonCImpl, activityRetainedCImpl, activityCImpl, view);
    }
  }

  private static final class ViewModelCBuilder implements NataSakuApplication_HiltComponents.ViewModelC.Builder {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private SavedStateHandle savedStateHandle;

    private ViewModelLifecycle viewModelLifecycle;

    private ViewModelCBuilder(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
    }

    @Override
    public ViewModelCBuilder savedStateHandle(SavedStateHandle handle) {
      this.savedStateHandle = Preconditions.checkNotNull(handle);
      return this;
    }

    @Override
    public ViewModelCBuilder viewModelLifecycle(ViewModelLifecycle viewModelLifecycle) {
      this.viewModelLifecycle = Preconditions.checkNotNull(viewModelLifecycle);
      return this;
    }

    @Override
    public NataSakuApplication_HiltComponents.ViewModelC build() {
      Preconditions.checkBuilderRequirement(savedStateHandle, SavedStateHandle.class);
      Preconditions.checkBuilderRequirement(viewModelLifecycle, ViewModelLifecycle.class);
      return new ViewModelCImpl(singletonCImpl, activityRetainedCImpl, savedStateHandle, viewModelLifecycle);
    }
  }

  private static final class ServiceCBuilder implements NataSakuApplication_HiltComponents.ServiceC.Builder {
    private final SingletonCImpl singletonCImpl;

    private Service service;

    private ServiceCBuilder(SingletonCImpl singletonCImpl) {
      this.singletonCImpl = singletonCImpl;
    }

    @Override
    public ServiceCBuilder service(Service service) {
      this.service = Preconditions.checkNotNull(service);
      return this;
    }

    @Override
    public NataSakuApplication_HiltComponents.ServiceC build() {
      Preconditions.checkBuilderRequirement(service, Service.class);
      return new ServiceCImpl(singletonCImpl, service);
    }
  }

  private static final class ViewWithFragmentCImpl extends NataSakuApplication_HiltComponents.ViewWithFragmentC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final FragmentCImpl fragmentCImpl;

    private final ViewWithFragmentCImpl viewWithFragmentCImpl = this;

    private ViewWithFragmentCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl,
        FragmentCImpl fragmentCImpl, View viewParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;
      this.fragmentCImpl = fragmentCImpl;


    }
  }

  private static final class FragmentCImpl extends NataSakuApplication_HiltComponents.FragmentC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final FragmentCImpl fragmentCImpl = this;

    private FragmentCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, ActivityCImpl activityCImpl,
        Fragment fragmentParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;


    }

    @Override
    public DefaultViewModelFactories.InternalFactoryFactory getHiltInternalFactoryFactory() {
      return activityCImpl.getHiltInternalFactoryFactory();
    }

    @Override
    public ViewWithFragmentComponentBuilder viewWithFragmentComponentBuilder() {
      return new ViewWithFragmentCBuilder(singletonCImpl, activityRetainedCImpl, activityCImpl, fragmentCImpl);
    }
  }

  private static final class ViewCImpl extends NataSakuApplication_HiltComponents.ViewC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl;

    private final ViewCImpl viewCImpl = this;

    private ViewCImpl(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
        ActivityCImpl activityCImpl, View viewParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;
      this.activityCImpl = activityCImpl;


    }
  }

  private static final class ActivityCImpl extends NataSakuApplication_HiltComponents.ActivityC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ActivityCImpl activityCImpl = this;

    private ActivityCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, Activity activityParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;


    }

    @Override
    public void injectMainActivity(MainActivity mainActivity) {
    }

    @Override
    public DefaultViewModelFactories.InternalFactoryFactory getHiltInternalFactoryFactory() {
      return DefaultViewModelFactories_InternalFactoryFactory_Factory.newInstance(getViewModelKeys(), new ViewModelCBuilder(singletonCImpl, activityRetainedCImpl));
    }

    @Override
    public Map<Class<?>, Boolean> getViewModelKeys() {
      return LazyClassKeyMap.<Boolean>of(MapBuilder.<String, Boolean>newMapBuilder(8).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_budget_BudgetViewModel, BudgetViewModel_HiltModules.KeyModule.provide()).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_home_HomeViewModel, HomeViewModel_HiltModules.KeyModule.provide()).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_report_MonthlyReportViewModel, MonthlyReportViewModel_HiltModules.KeyModule.provide()).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_saving_SavingViewModel, SavingViewModel_HiltModules.KeyModule.provide()).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_settings_SettingsViewModel, SettingsViewModel_HiltModules.KeyModule.provide()).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_setup_SetupViewModel, SetupViewModel_HiltModules.KeyModule.provide()).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_splash_SplashViewModel, SplashViewModel_HiltModules.KeyModule.provide()).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_transaction_TransactionHistoryViewModel, TransactionHistoryViewModel_HiltModules.KeyModule.provide()).build());
    }

    @Override
    public ViewModelComponentBuilder getViewModelComponentBuilder() {
      return new ViewModelCBuilder(singletonCImpl, activityRetainedCImpl);
    }

    @Override
    public FragmentComponentBuilder fragmentComponentBuilder() {
      return new FragmentCBuilder(singletonCImpl, activityRetainedCImpl, activityCImpl);
    }

    @Override
    public ViewComponentBuilder viewComponentBuilder() {
      return new ViewCBuilder(singletonCImpl, activityRetainedCImpl, activityCImpl);
    }

    @IdentifierNameString
    private static final class LazyClassKeyProvider {
      static String com_natasaku_app_presentation_screen_splash_SplashViewModel = "com.natasaku.app.presentation.screen.splash.SplashViewModel";

      static String com_natasaku_app_presentation_screen_settings_SettingsViewModel = "com.natasaku.app.presentation.screen.settings.SettingsViewModel";

      static String com_natasaku_app_presentation_screen_saving_SavingViewModel = "com.natasaku.app.presentation.screen.saving.SavingViewModel";

      static String com_natasaku_app_presentation_screen_budget_BudgetViewModel = "com.natasaku.app.presentation.screen.budget.BudgetViewModel";

      static String com_natasaku_app_presentation_screen_setup_SetupViewModel = "com.natasaku.app.presentation.screen.setup.SetupViewModel";

      static String com_natasaku_app_presentation_screen_report_MonthlyReportViewModel = "com.natasaku.app.presentation.screen.report.MonthlyReportViewModel";

      static String com_natasaku_app_presentation_screen_transaction_TransactionHistoryViewModel = "com.natasaku.app.presentation.screen.transaction.TransactionHistoryViewModel";

      static String com_natasaku_app_presentation_screen_home_HomeViewModel = "com.natasaku.app.presentation.screen.home.HomeViewModel";

      @KeepFieldType
      SplashViewModel com_natasaku_app_presentation_screen_splash_SplashViewModel2;

      @KeepFieldType
      SettingsViewModel com_natasaku_app_presentation_screen_settings_SettingsViewModel2;

      @KeepFieldType
      SavingViewModel com_natasaku_app_presentation_screen_saving_SavingViewModel2;

      @KeepFieldType
      BudgetViewModel com_natasaku_app_presentation_screen_budget_BudgetViewModel2;

      @KeepFieldType
      SetupViewModel com_natasaku_app_presentation_screen_setup_SetupViewModel2;

      @KeepFieldType
      MonthlyReportViewModel com_natasaku_app_presentation_screen_report_MonthlyReportViewModel2;

      @KeepFieldType
      TransactionHistoryViewModel com_natasaku_app_presentation_screen_transaction_TransactionHistoryViewModel2;

      @KeepFieldType
      HomeViewModel com_natasaku_app_presentation_screen_home_HomeViewModel2;
    }
  }

  private static final class ViewModelCImpl extends NataSakuApplication_HiltComponents.ViewModelC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl;

    private final ViewModelCImpl viewModelCImpl = this;

    private Provider<BudgetViewModel> budgetViewModelProvider;

    private Provider<HomeViewModel> homeViewModelProvider;

    private Provider<MonthlyReportViewModel> monthlyReportViewModelProvider;

    private Provider<SavingViewModel> savingViewModelProvider;

    private Provider<SettingsViewModel> settingsViewModelProvider;

    private Provider<SetupViewModel> setupViewModelProvider;

    private Provider<SplashViewModel> splashViewModelProvider;

    private Provider<TransactionHistoryViewModel> transactionHistoryViewModelProvider;

    private ViewModelCImpl(SingletonCImpl singletonCImpl,
        ActivityRetainedCImpl activityRetainedCImpl, SavedStateHandle savedStateHandleParam,
        ViewModelLifecycle viewModelLifecycleParam) {
      this.singletonCImpl = singletonCImpl;
      this.activityRetainedCImpl = activityRetainedCImpl;

      initialize(savedStateHandleParam, viewModelLifecycleParam);

    }

    @SuppressWarnings("unchecked")
    private void initialize(final SavedStateHandle savedStateHandleParam,
        final ViewModelLifecycle viewModelLifecycleParam) {
      this.budgetViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 0);
      this.homeViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 1);
      this.monthlyReportViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 2);
      this.savingViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 3);
      this.settingsViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 4);
      this.setupViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 5);
      this.splashViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 6);
      this.transactionHistoryViewModelProvider = new SwitchingProvider<>(singletonCImpl, activityRetainedCImpl, viewModelCImpl, 7);
    }

    @Override
    public Map<Class<?>, javax.inject.Provider<ViewModel>> getHiltViewModelMap() {
      return LazyClassKeyMap.<javax.inject.Provider<ViewModel>>of(MapBuilder.<String, javax.inject.Provider<ViewModel>>newMapBuilder(8).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_budget_BudgetViewModel, ((Provider) budgetViewModelProvider)).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_home_HomeViewModel, ((Provider) homeViewModelProvider)).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_report_MonthlyReportViewModel, ((Provider) monthlyReportViewModelProvider)).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_saving_SavingViewModel, ((Provider) savingViewModelProvider)).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_settings_SettingsViewModel, ((Provider) settingsViewModelProvider)).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_setup_SetupViewModel, ((Provider) setupViewModelProvider)).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_splash_SplashViewModel, ((Provider) splashViewModelProvider)).put(LazyClassKeyProvider.com_natasaku_app_presentation_screen_transaction_TransactionHistoryViewModel, ((Provider) transactionHistoryViewModelProvider)).build());
    }

    @Override
    public Map<Class<?>, Object> getHiltViewModelAssistedMap() {
      return Collections.<Class<?>, Object>emptyMap();
    }

    @IdentifierNameString
    private static final class LazyClassKeyProvider {
      static String com_natasaku_app_presentation_screen_budget_BudgetViewModel = "com.natasaku.app.presentation.screen.budget.BudgetViewModel";

      static String com_natasaku_app_presentation_screen_saving_SavingViewModel = "com.natasaku.app.presentation.screen.saving.SavingViewModel";

      static String com_natasaku_app_presentation_screen_transaction_TransactionHistoryViewModel = "com.natasaku.app.presentation.screen.transaction.TransactionHistoryViewModel";

      static String com_natasaku_app_presentation_screen_home_HomeViewModel = "com.natasaku.app.presentation.screen.home.HomeViewModel";

      static String com_natasaku_app_presentation_screen_settings_SettingsViewModel = "com.natasaku.app.presentation.screen.settings.SettingsViewModel";

      static String com_natasaku_app_presentation_screen_setup_SetupViewModel = "com.natasaku.app.presentation.screen.setup.SetupViewModel";

      static String com_natasaku_app_presentation_screen_report_MonthlyReportViewModel = "com.natasaku.app.presentation.screen.report.MonthlyReportViewModel";

      static String com_natasaku_app_presentation_screen_splash_SplashViewModel = "com.natasaku.app.presentation.screen.splash.SplashViewModel";

      @KeepFieldType
      BudgetViewModel com_natasaku_app_presentation_screen_budget_BudgetViewModel2;

      @KeepFieldType
      SavingViewModel com_natasaku_app_presentation_screen_saving_SavingViewModel2;

      @KeepFieldType
      TransactionHistoryViewModel com_natasaku_app_presentation_screen_transaction_TransactionHistoryViewModel2;

      @KeepFieldType
      HomeViewModel com_natasaku_app_presentation_screen_home_HomeViewModel2;

      @KeepFieldType
      SettingsViewModel com_natasaku_app_presentation_screen_settings_SettingsViewModel2;

      @KeepFieldType
      SetupViewModel com_natasaku_app_presentation_screen_setup_SetupViewModel2;

      @KeepFieldType
      MonthlyReportViewModel com_natasaku_app_presentation_screen_report_MonthlyReportViewModel2;

      @KeepFieldType
      SplashViewModel com_natasaku_app_presentation_screen_splash_SplashViewModel2;
    }

    private static final class SwitchingProvider<T> implements Provider<T> {
      private final SingletonCImpl singletonCImpl;

      private final ActivityRetainedCImpl activityRetainedCImpl;

      private final ViewModelCImpl viewModelCImpl;

      private final int id;

      SwitchingProvider(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
          ViewModelCImpl viewModelCImpl, int id) {
        this.singletonCImpl = singletonCImpl;
        this.activityRetainedCImpl = activityRetainedCImpl;
        this.viewModelCImpl = viewModelCImpl;
        this.id = id;
      }

      @SuppressWarnings("unchecked")
      @Override
      public T get() {
        switch (id) {
          case 0: // com.natasaku.app.presentation.screen.budget.BudgetViewModel 
          return (T) new BudgetViewModel(singletonCImpl.budgetPeriodDao(), singletonCImpl.incomeSourceDao(), singletonCImpl.fixedExpenseDao(), singletonCImpl.savingTargetDao(), singletonCImpl.expenseTransactionDao(), AppModule_ProvideBudgetCalculatorFactory.provideBudgetCalculator(), AppModule_ProvideDailyBudgetCalculatorFactory.provideDailyBudgetCalculator(), AppModule_ProvideOverbudgetCalculatorFactory.provideOverbudgetCalculator());

          case 1: // com.natasaku.app.presentation.screen.home.HomeViewModel 
          return (T) new HomeViewModel(singletonCImpl.budgetPeriodDao(), singletonCImpl.expenseTransactionDao(), singletonCImpl.incomeSourceDao(), singletonCImpl.fixedExpenseDao(), singletonCImpl.savingTargetDao(), singletonCImpl.dailyBudgetSnapshotDao(), AppModule_ProvideBudgetCalculatorFactory.provideBudgetCalculator(), AppModule_ProvideDailyBudgetCalculatorFactory.provideDailyBudgetCalculator(), AppModule_ProvideOverbudgetCalculatorFactory.provideOverbudgetCalculator());

          case 2: // com.natasaku.app.presentation.screen.report.MonthlyReportViewModel 
          return (T) new MonthlyReportViewModel(singletonCImpl.budgetPeriodDao(), singletonCImpl.incomeSourceDao(), singletonCImpl.expenseTransactionDao(), singletonCImpl.fixedExpenseDao(), singletonCImpl.savingAllocationDao(), AppModule_ProvideMonthlyReportCalculatorFactory.provideMonthlyReportCalculator(), AppModule_ProvideDailyBudgetCalculatorFactory.provideDailyBudgetCalculator(), singletonCImpl.provideMonthlyReportExportersProvider.get());

          case 3: // com.natasaku.app.presentation.screen.saving.SavingViewModel 
          return (T) new SavingViewModel(singletonCImpl.budgetPeriodDao(), singletonCImpl.savingTargetDao(), singletonCImpl.savingAllocationDao(), singletonCImpl.dailyBudgetSnapshotDao(), singletonCImpl.provideSettingsRepositoryProvider.get(), AppModule_ProvideLeftoverAllocationCalculatorFactory.provideLeftoverAllocationCalculator());

          case 4: // com.natasaku.app.presentation.screen.settings.SettingsViewModel 
          return (T) new SettingsViewModel(singletonCImpl.provideSettingsRepositoryProvider.get(), singletonCImpl.provideBackupRestoreServiceProvider.get(), singletonCImpl.provideReminderSchedulerProvider.get());

          case 5: // com.natasaku.app.presentation.screen.setup.SetupViewModel 
          return (T) new SetupViewModel(AppModule_ProvideBudgetCalculatorFactory.provideBudgetCalculator(), AppModule_ProvideDailyBudgetCalculatorFactory.provideDailyBudgetCalculator(), singletonCImpl.provideCompleteSetupUseCaseProvider.get());

          case 6: // com.natasaku.app.presentation.screen.splash.SplashViewModel 
          return (T) new SplashViewModel(singletonCImpl.provideSettingsRepositoryProvider.get(), singletonCImpl.budgetPeriodDao());

          case 7: // com.natasaku.app.presentation.screen.transaction.TransactionHistoryViewModel 
          return (T) new TransactionHistoryViewModel(singletonCImpl.budgetPeriodDao(), singletonCImpl.expenseTransactionDao());

          default: throw new AssertionError(id);
        }
      }
    }
  }

  private static final class ActivityRetainedCImpl extends NataSakuApplication_HiltComponents.ActivityRetainedC {
    private final SingletonCImpl singletonCImpl;

    private final ActivityRetainedCImpl activityRetainedCImpl = this;

    private Provider<ActivityRetainedLifecycle> provideActivityRetainedLifecycleProvider;

    private ActivityRetainedCImpl(SingletonCImpl singletonCImpl,
        SavedStateHandleHolder savedStateHandleHolderParam) {
      this.singletonCImpl = singletonCImpl;

      initialize(savedStateHandleHolderParam);

    }

    @SuppressWarnings("unchecked")
    private void initialize(final SavedStateHandleHolder savedStateHandleHolderParam) {
      this.provideActivityRetainedLifecycleProvider = DoubleCheck.provider(new SwitchingProvider<ActivityRetainedLifecycle>(singletonCImpl, activityRetainedCImpl, 0));
    }

    @Override
    public ActivityComponentBuilder activityComponentBuilder() {
      return new ActivityCBuilder(singletonCImpl, activityRetainedCImpl);
    }

    @Override
    public ActivityRetainedLifecycle getActivityRetainedLifecycle() {
      return provideActivityRetainedLifecycleProvider.get();
    }

    private static final class SwitchingProvider<T> implements Provider<T> {
      private final SingletonCImpl singletonCImpl;

      private final ActivityRetainedCImpl activityRetainedCImpl;

      private final int id;

      SwitchingProvider(SingletonCImpl singletonCImpl, ActivityRetainedCImpl activityRetainedCImpl,
          int id) {
        this.singletonCImpl = singletonCImpl;
        this.activityRetainedCImpl = activityRetainedCImpl;
        this.id = id;
      }

      @SuppressWarnings("unchecked")
      @Override
      public T get() {
        switch (id) {
          case 0: // dagger.hilt.android.ActivityRetainedLifecycle 
          return (T) ActivityRetainedComponentManager_LifecycleModule_ProvideActivityRetainedLifecycleFactory.provideActivityRetainedLifecycle();

          default: throw new AssertionError(id);
        }
      }
    }
  }

  private static final class ServiceCImpl extends NataSakuApplication_HiltComponents.ServiceC {
    private final SingletonCImpl singletonCImpl;

    private final ServiceCImpl serviceCImpl = this;

    private ServiceCImpl(SingletonCImpl singletonCImpl, Service serviceParam) {
      this.singletonCImpl = singletonCImpl;


    }
  }

  private static final class SingletonCImpl extends NataSakuApplication_HiltComponents.SingletonC {
    private final ApplicationContextModule applicationContextModule;

    private final SingletonCImpl singletonCImpl = this;

    private Provider<NataSakuDatabase> provideDatabaseProvider;

    private Provider<MonthlyReportExporters> provideMonthlyReportExportersProvider;

    private Provider<UserPreferenceDataStore> provideUserPreferenceDataStoreProvider;

    private Provider<SettingsRepository> provideSettingsRepositoryProvider;

    private Provider<BackupRestoreService> provideBackupRestoreServiceProvider;

    private Provider<ReminderScheduler> provideReminderSchedulerProvider;

    private Provider<CompleteSetupUseCase> provideCompleteSetupUseCaseProvider;

    private SingletonCImpl(ApplicationContextModule applicationContextModuleParam) {
      this.applicationContextModule = applicationContextModuleParam;
      initialize(applicationContextModuleParam);

    }

    private BudgetPeriodDao budgetPeriodDao() {
      return AppModule_ProvideBudgetPeriodDaoFactory.provideBudgetPeriodDao(provideDatabaseProvider.get());
    }

    private IncomeSourceDao incomeSourceDao() {
      return AppModule_ProvideIncomeSourceDaoFactory.provideIncomeSourceDao(provideDatabaseProvider.get());
    }

    private FixedExpenseDao fixedExpenseDao() {
      return AppModule_ProvideFixedExpenseDaoFactory.provideFixedExpenseDao(provideDatabaseProvider.get());
    }

    private SavingTargetDao savingTargetDao() {
      return AppModule_ProvideSavingTargetDaoFactory.provideSavingTargetDao(provideDatabaseProvider.get());
    }

    private ExpenseTransactionDao expenseTransactionDao() {
      return AppModule_ProvideExpenseTransactionDaoFactory.provideExpenseTransactionDao(provideDatabaseProvider.get());
    }

    private DailyBudgetSnapshotDao dailyBudgetSnapshotDao() {
      return AppModule_ProvideDailyBudgetSnapshotDaoFactory.provideDailyBudgetSnapshotDao(provideDatabaseProvider.get());
    }

    private SavingAllocationDao savingAllocationDao() {
      return AppModule_ProvideSavingAllocationDaoFactory.provideSavingAllocationDao(provideDatabaseProvider.get());
    }

    private BackupRestoreDao backupRestoreDao() {
      return AppModule_ProvideBackupRestoreDaoFactory.provideBackupRestoreDao(provideDatabaseProvider.get());
    }

    @SuppressWarnings("unchecked")
    private void initialize(final ApplicationContextModule applicationContextModuleParam) {
      this.provideDatabaseProvider = DoubleCheck.provider(new SwitchingProvider<NataSakuDatabase>(singletonCImpl, 0));
      this.provideMonthlyReportExportersProvider = DoubleCheck.provider(new SwitchingProvider<MonthlyReportExporters>(singletonCImpl, 1));
      this.provideUserPreferenceDataStoreProvider = DoubleCheck.provider(new SwitchingProvider<UserPreferenceDataStore>(singletonCImpl, 3));
      this.provideSettingsRepositoryProvider = DoubleCheck.provider(new SwitchingProvider<SettingsRepository>(singletonCImpl, 2));
      this.provideBackupRestoreServiceProvider = DoubleCheck.provider(new SwitchingProvider<BackupRestoreService>(singletonCImpl, 4));
      this.provideReminderSchedulerProvider = DoubleCheck.provider(new SwitchingProvider<ReminderScheduler>(singletonCImpl, 5));
      this.provideCompleteSetupUseCaseProvider = DoubleCheck.provider(new SwitchingProvider<CompleteSetupUseCase>(singletonCImpl, 6));
    }

    @Override
    public void injectNataSakuApplication(NataSakuApplication nataSakuApplication) {
    }

    @Override
    public Set<Boolean> getDisableFragmentGetContextFix() {
      return Collections.<Boolean>emptySet();
    }

    @Override
    public ActivityRetainedComponentBuilder retainedComponentBuilder() {
      return new ActivityRetainedCBuilder(singletonCImpl);
    }

    @Override
    public ServiceComponentBuilder serviceComponentBuilder() {
      return new ServiceCBuilder(singletonCImpl);
    }

    private static final class SwitchingProvider<T> implements Provider<T> {
      private final SingletonCImpl singletonCImpl;

      private final int id;

      SwitchingProvider(SingletonCImpl singletonCImpl, int id) {
        this.singletonCImpl = singletonCImpl;
        this.id = id;
      }

      @SuppressWarnings("unchecked")
      @Override
      public T get() {
        switch (id) {
          case 0: // com.natasaku.app.data.local.database.NataSakuDatabase 
          return (T) AppModule_ProvideDatabaseFactory.provideDatabase(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 1: // com.natasaku.app.data.export.MonthlyReportExporters 
          return (T) AppModule_ProvideMonthlyReportExportersFactory.provideMonthlyReportExporters(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 2: // com.natasaku.app.domain.repository.SettingsRepository 
          return (T) AppModule_ProvideSettingsRepositoryFactory.provideSettingsRepository(singletonCImpl.provideUserPreferenceDataStoreProvider.get());

          case 3: // com.natasaku.app.data.datastore.UserPreferenceDataStore 
          return (T) AppModule_ProvideUserPreferenceDataStoreFactory.provideUserPreferenceDataStore(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 4: // com.natasaku.app.data.export.BackupRestoreService 
          return (T) AppModule_ProvideBackupRestoreServiceFactory.provideBackupRestoreService(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule), singletonCImpl.provideDatabaseProvider.get(), singletonCImpl.budgetPeriodDao(), singletonCImpl.incomeSourceDao(), singletonCImpl.fixedExpenseDao(), singletonCImpl.expenseTransactionDao(), singletonCImpl.savingTargetDao(), singletonCImpl.savingAllocationDao(), singletonCImpl.dailyBudgetSnapshotDao(), singletonCImpl.backupRestoreDao(), singletonCImpl.provideUserPreferenceDataStoreProvider.get());

          case 5: // com.natasaku.app.reminder.ReminderScheduler 
          return (T) AppModule_ProvideReminderSchedulerFactory.provideReminderScheduler(ApplicationContextModule_ProvideContextFactory.provideContext(singletonCImpl.applicationContextModule));

          case 6: // com.natasaku.app.domain.usecase.CompleteSetupUseCase 
          return (T) AppModule_ProvideCompleteSetupUseCaseFactory.provideCompleteSetupUseCase(singletonCImpl.provideDatabaseProvider.get(), singletonCImpl.budgetPeriodDao(), singletonCImpl.provideUserPreferenceDataStoreProvider.get());

          default: throw new AssertionError(id);
        }
      }
    }
  }
}
