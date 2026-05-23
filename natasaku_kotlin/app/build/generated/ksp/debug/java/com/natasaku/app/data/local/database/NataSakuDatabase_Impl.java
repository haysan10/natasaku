package com.natasaku.app.data.local.database;

import androidx.annotation.NonNull;
import androidx.room.DatabaseConfiguration;
import androidx.room.InvalidationTracker;
import androidx.room.RoomDatabase;
import androidx.room.RoomOpenHelper;
import androidx.room.migration.AutoMigrationSpec;
import androidx.room.migration.Migration;
import androidx.room.util.DBUtil;
import androidx.room.util.TableInfo;
import androidx.sqlite.db.SupportSQLiteDatabase;
import androidx.sqlite.db.SupportSQLiteOpenHelper;
import com.natasaku.app.data.local.dao.BackupRestoreDao;
import com.natasaku.app.data.local.dao.BackupRestoreDao_Impl;
import com.natasaku.app.data.local.dao.BudgetPeriodDao;
import com.natasaku.app.data.local.dao.BudgetPeriodDao_Impl;
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao;
import com.natasaku.app.data.local.dao.DailyBudgetSnapshotDao_Impl;
import com.natasaku.app.data.local.dao.ExpenseTransactionDao;
import com.natasaku.app.data.local.dao.ExpenseTransactionDao_Impl;
import com.natasaku.app.data.local.dao.FixedExpenseDao;
import com.natasaku.app.data.local.dao.FixedExpenseDao_Impl;
import com.natasaku.app.data.local.dao.IncomeSourceDao;
import com.natasaku.app.data.local.dao.IncomeSourceDao_Impl;
import com.natasaku.app.data.local.dao.SavingAllocationDao;
import com.natasaku.app.data.local.dao.SavingAllocationDao_Impl;
import com.natasaku.app.data.local.dao.SavingTargetDao;
import com.natasaku.app.data.local.dao.SavingTargetDao_Impl;
import java.lang.Class;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.annotation.processing.Generated;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class NataSakuDatabase_Impl extends NataSakuDatabase {
  private volatile BudgetPeriodDao _budgetPeriodDao;

  private volatile IncomeSourceDao _incomeSourceDao;

  private volatile FixedExpenseDao _fixedExpenseDao;

  private volatile ExpenseTransactionDao _expenseTransactionDao;

  private volatile SavingTargetDao _savingTargetDao;

  private volatile SavingAllocationDao _savingAllocationDao;

  private volatile DailyBudgetSnapshotDao _dailyBudgetSnapshotDao;

  private volatile BackupRestoreDao _backupRestoreDao;

  @Override
  @NonNull
  protected SupportSQLiteOpenHelper createOpenHelper(@NonNull final DatabaseConfiguration config) {
    final SupportSQLiteOpenHelper.Callback _openCallback = new RoomOpenHelper(config, new RoomOpenHelper.Delegate(2) {
      @Override
      public void createAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("CREATE TABLE IF NOT EXISTS `budget_period` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `startDate` TEXT NOT NULL, `endDate` TEXT NOT NULL, `isActive` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_budget_period_isActive` ON `budget_period` (`isActive`)");
        db.execSQL("CREATE TABLE IF NOT EXISTS `income_source` (`id` TEXT NOT NULL, `periodId` TEXT NOT NULL, `name` TEXT NOT NULL, `amount` INTEGER NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_income_source_periodId` ON `income_source` (`periodId`)");
        db.execSQL("CREATE TABLE IF NOT EXISTS `fixed_expense` (`id` TEXT NOT NULL, `periodId` TEXT NOT NULL, `name` TEXT NOT NULL, `amount` INTEGER NOT NULL, `dueDay` INTEGER NOT NULL, `status` TEXT NOT NULL, `snoozedUntilTs` INTEGER, `paidAt` INTEGER, `createdAt` INTEGER NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_fixed_expense_periodId` ON `fixed_expense` (`periodId`)");
        db.execSQL("CREATE TABLE IF NOT EXISTS `expense_transaction` (`id` TEXT NOT NULL, `periodId` TEXT NOT NULL, `amount` INTEGER NOT NULL, `category` TEXT NOT NULL, `date` TEXT NOT NULL, `note` TEXT, `createdAt` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, `deletedAt` INTEGER, `source` TEXT NOT NULL, `fixedExpenseId` TEXT, PRIMARY KEY(`id`))");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_expense_transaction_periodId` ON `expense_transaction` (`periodId`)");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_expense_transaction_date` ON `expense_transaction` (`date`)");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_expense_transaction_periodId_date` ON `expense_transaction` (`periodId`, `date`)");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_expense_transaction_deletedAt` ON `expense_transaction` (`deletedAt`)");
        db.execSQL("CREATE TABLE IF NOT EXISTS `saving_target` (`id` TEXT NOT NULL, `periodId` TEXT NOT NULL, `targetAmount` INTEGER NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_saving_target_periodId` ON `saving_target` (`periodId`)");
        db.execSQL("CREATE TABLE IF NOT EXISTS `saving_allocation` (`id` TEXT NOT NULL, `periodId` TEXT NOT NULL, `amount` INTEGER NOT NULL, `date` TEXT NOT NULL, `source` TEXT NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_saving_allocation_periodId` ON `saving_allocation` (`periodId`)");
        db.execSQL("CREATE INDEX IF NOT EXISTS `index_saving_allocation_date` ON `saving_allocation` (`date`)");
        db.execSQL("CREATE TABLE IF NOT EXISTS `daily_budget_snapshot` (`id` TEXT NOT NULL, `periodId` TEXT NOT NULL, `date` TEXT NOT NULL, `finalDailyAllowance` INTEGER NOT NULL, `spentToday` INTEGER NOT NULL, `remainingToday` INTEGER NOT NULL, PRIMARY KEY(`id`))");
        db.execSQL("CREATE UNIQUE INDEX IF NOT EXISTS `index_daily_budget_snapshot_periodId_date` ON `daily_budget_snapshot` (`periodId`, `date`)");
        db.execSQL("CREATE TABLE IF NOT EXISTS room_master_table (id INTEGER PRIMARY KEY,identity_hash TEXT)");
        db.execSQL("INSERT OR REPLACE INTO room_master_table (id,identity_hash) VALUES(42, '251a04abfd905c9ef40a8a69f75a9c36')");
      }

      @Override
      public void dropAllTables(@NonNull final SupportSQLiteDatabase db) {
        db.execSQL("DROP TABLE IF EXISTS `budget_period`");
        db.execSQL("DROP TABLE IF EXISTS `income_source`");
        db.execSQL("DROP TABLE IF EXISTS `fixed_expense`");
        db.execSQL("DROP TABLE IF EXISTS `expense_transaction`");
        db.execSQL("DROP TABLE IF EXISTS `saving_target`");
        db.execSQL("DROP TABLE IF EXISTS `saving_allocation`");
        db.execSQL("DROP TABLE IF EXISTS `daily_budget_snapshot`");
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onDestructiveMigration(db);
          }
        }
      }

      @Override
      public void onCreate(@NonNull final SupportSQLiteDatabase db) {
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onCreate(db);
          }
        }
      }

      @Override
      public void onOpen(@NonNull final SupportSQLiteDatabase db) {
        mDatabase = db;
        internalInitInvalidationTracker(db);
        final List<? extends RoomDatabase.Callback> _callbacks = mCallbacks;
        if (_callbacks != null) {
          for (RoomDatabase.Callback _callback : _callbacks) {
            _callback.onOpen(db);
          }
        }
      }

      @Override
      public void onPreMigrate(@NonNull final SupportSQLiteDatabase db) {
        DBUtil.dropFtsSyncTriggers(db);
      }

      @Override
      public void onPostMigrate(@NonNull final SupportSQLiteDatabase db) {
      }

      @Override
      @NonNull
      public RoomOpenHelper.ValidationResult onValidateSchema(
          @NonNull final SupportSQLiteDatabase db) {
        final HashMap<String, TableInfo.Column> _columnsBudgetPeriod = new HashMap<String, TableInfo.Column>(7);
        _columnsBudgetPeriod.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsBudgetPeriod.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsBudgetPeriod.put("startDate", new TableInfo.Column("startDate", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsBudgetPeriod.put("endDate", new TableInfo.Column("endDate", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsBudgetPeriod.put("isActive", new TableInfo.Column("isActive", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsBudgetPeriod.put("createdAt", new TableInfo.Column("createdAt", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsBudgetPeriod.put("updatedAt", new TableInfo.Column("updatedAt", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysBudgetPeriod = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesBudgetPeriod = new HashSet<TableInfo.Index>(1);
        _indicesBudgetPeriod.add(new TableInfo.Index("index_budget_period_isActive", false, Arrays.asList("isActive"), Arrays.asList("ASC")));
        final TableInfo _infoBudgetPeriod = new TableInfo("budget_period", _columnsBudgetPeriod, _foreignKeysBudgetPeriod, _indicesBudgetPeriod);
        final TableInfo _existingBudgetPeriod = TableInfo.read(db, "budget_period");
        if (!_infoBudgetPeriod.equals(_existingBudgetPeriod)) {
          return new RoomOpenHelper.ValidationResult(false, "budget_period(com.natasaku.app.data.local.entity.BudgetPeriodEntity).\n"
                  + " Expected:\n" + _infoBudgetPeriod + "\n"
                  + " Found:\n" + _existingBudgetPeriod);
        }
        final HashMap<String, TableInfo.Column> _columnsIncomeSource = new HashMap<String, TableInfo.Column>(4);
        _columnsIncomeSource.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsIncomeSource.put("periodId", new TableInfo.Column("periodId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsIncomeSource.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsIncomeSource.put("amount", new TableInfo.Column("amount", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysIncomeSource = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesIncomeSource = new HashSet<TableInfo.Index>(1);
        _indicesIncomeSource.add(new TableInfo.Index("index_income_source_periodId", false, Arrays.asList("periodId"), Arrays.asList("ASC")));
        final TableInfo _infoIncomeSource = new TableInfo("income_source", _columnsIncomeSource, _foreignKeysIncomeSource, _indicesIncomeSource);
        final TableInfo _existingIncomeSource = TableInfo.read(db, "income_source");
        if (!_infoIncomeSource.equals(_existingIncomeSource)) {
          return new RoomOpenHelper.ValidationResult(false, "income_source(com.natasaku.app.data.local.entity.IncomeSourceEntity).\n"
                  + " Expected:\n" + _infoIncomeSource + "\n"
                  + " Found:\n" + _existingIncomeSource);
        }
        final HashMap<String, TableInfo.Column> _columnsFixedExpense = new HashMap<String, TableInfo.Column>(9);
        _columnsFixedExpense.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("periodId", new TableInfo.Column("periodId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("name", new TableInfo.Column("name", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("amount", new TableInfo.Column("amount", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("dueDay", new TableInfo.Column("dueDay", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("status", new TableInfo.Column("status", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("snoozedUntilTs", new TableInfo.Column("snoozedUntilTs", "INTEGER", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("paidAt", new TableInfo.Column("paidAt", "INTEGER", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsFixedExpense.put("createdAt", new TableInfo.Column("createdAt", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysFixedExpense = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesFixedExpense = new HashSet<TableInfo.Index>(1);
        _indicesFixedExpense.add(new TableInfo.Index("index_fixed_expense_periodId", false, Arrays.asList("periodId"), Arrays.asList("ASC")));
        final TableInfo _infoFixedExpense = new TableInfo("fixed_expense", _columnsFixedExpense, _foreignKeysFixedExpense, _indicesFixedExpense);
        final TableInfo _existingFixedExpense = TableInfo.read(db, "fixed_expense");
        if (!_infoFixedExpense.equals(_existingFixedExpense)) {
          return new RoomOpenHelper.ValidationResult(false, "fixed_expense(com.natasaku.app.data.local.entity.FixedExpenseEntity).\n"
                  + " Expected:\n" + _infoFixedExpense + "\n"
                  + " Found:\n" + _existingFixedExpense);
        }
        final HashMap<String, TableInfo.Column> _columnsExpenseTransaction = new HashMap<String, TableInfo.Column>(11);
        _columnsExpenseTransaction.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("periodId", new TableInfo.Column("periodId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("amount", new TableInfo.Column("amount", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("category", new TableInfo.Column("category", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("date", new TableInfo.Column("date", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("note", new TableInfo.Column("note", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("createdAt", new TableInfo.Column("createdAt", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("updatedAt", new TableInfo.Column("updatedAt", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("deletedAt", new TableInfo.Column("deletedAt", "INTEGER", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("source", new TableInfo.Column("source", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsExpenseTransaction.put("fixedExpenseId", new TableInfo.Column("fixedExpenseId", "TEXT", false, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysExpenseTransaction = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesExpenseTransaction = new HashSet<TableInfo.Index>(4);
        _indicesExpenseTransaction.add(new TableInfo.Index("index_expense_transaction_periodId", false, Arrays.asList("periodId"), Arrays.asList("ASC")));
        _indicesExpenseTransaction.add(new TableInfo.Index("index_expense_transaction_date", false, Arrays.asList("date"), Arrays.asList("ASC")));
        _indicesExpenseTransaction.add(new TableInfo.Index("index_expense_transaction_periodId_date", false, Arrays.asList("periodId", "date"), Arrays.asList("ASC", "ASC")));
        _indicesExpenseTransaction.add(new TableInfo.Index("index_expense_transaction_deletedAt", false, Arrays.asList("deletedAt"), Arrays.asList("ASC")));
        final TableInfo _infoExpenseTransaction = new TableInfo("expense_transaction", _columnsExpenseTransaction, _foreignKeysExpenseTransaction, _indicesExpenseTransaction);
        final TableInfo _existingExpenseTransaction = TableInfo.read(db, "expense_transaction");
        if (!_infoExpenseTransaction.equals(_existingExpenseTransaction)) {
          return new RoomOpenHelper.ValidationResult(false, "expense_transaction(com.natasaku.app.data.local.entity.ExpenseTransactionEntity).\n"
                  + " Expected:\n" + _infoExpenseTransaction + "\n"
                  + " Found:\n" + _existingExpenseTransaction);
        }
        final HashMap<String, TableInfo.Column> _columnsSavingTarget = new HashMap<String, TableInfo.Column>(3);
        _columnsSavingTarget.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSavingTarget.put("periodId", new TableInfo.Column("periodId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSavingTarget.put("targetAmount", new TableInfo.Column("targetAmount", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysSavingTarget = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesSavingTarget = new HashSet<TableInfo.Index>(1);
        _indicesSavingTarget.add(new TableInfo.Index("index_saving_target_periodId", false, Arrays.asList("periodId"), Arrays.asList("ASC")));
        final TableInfo _infoSavingTarget = new TableInfo("saving_target", _columnsSavingTarget, _foreignKeysSavingTarget, _indicesSavingTarget);
        final TableInfo _existingSavingTarget = TableInfo.read(db, "saving_target");
        if (!_infoSavingTarget.equals(_existingSavingTarget)) {
          return new RoomOpenHelper.ValidationResult(false, "saving_target(com.natasaku.app.data.local.entity.SavingTargetEntity).\n"
                  + " Expected:\n" + _infoSavingTarget + "\n"
                  + " Found:\n" + _existingSavingTarget);
        }
        final HashMap<String, TableInfo.Column> _columnsSavingAllocation = new HashMap<String, TableInfo.Column>(5);
        _columnsSavingAllocation.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSavingAllocation.put("periodId", new TableInfo.Column("periodId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSavingAllocation.put("amount", new TableInfo.Column("amount", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSavingAllocation.put("date", new TableInfo.Column("date", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsSavingAllocation.put("source", new TableInfo.Column("source", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysSavingAllocation = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesSavingAllocation = new HashSet<TableInfo.Index>(2);
        _indicesSavingAllocation.add(new TableInfo.Index("index_saving_allocation_periodId", false, Arrays.asList("periodId"), Arrays.asList("ASC")));
        _indicesSavingAllocation.add(new TableInfo.Index("index_saving_allocation_date", false, Arrays.asList("date"), Arrays.asList("ASC")));
        final TableInfo _infoSavingAllocation = new TableInfo("saving_allocation", _columnsSavingAllocation, _foreignKeysSavingAllocation, _indicesSavingAllocation);
        final TableInfo _existingSavingAllocation = TableInfo.read(db, "saving_allocation");
        if (!_infoSavingAllocation.equals(_existingSavingAllocation)) {
          return new RoomOpenHelper.ValidationResult(false, "saving_allocation(com.natasaku.app.data.local.entity.SavingAllocationEntity).\n"
                  + " Expected:\n" + _infoSavingAllocation + "\n"
                  + " Found:\n" + _existingSavingAllocation);
        }
        final HashMap<String, TableInfo.Column> _columnsDailyBudgetSnapshot = new HashMap<String, TableInfo.Column>(6);
        _columnsDailyBudgetSnapshot.put("id", new TableInfo.Column("id", "TEXT", true, 1, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDailyBudgetSnapshot.put("periodId", new TableInfo.Column("periodId", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDailyBudgetSnapshot.put("date", new TableInfo.Column("date", "TEXT", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDailyBudgetSnapshot.put("finalDailyAllowance", new TableInfo.Column("finalDailyAllowance", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDailyBudgetSnapshot.put("spentToday", new TableInfo.Column("spentToday", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        _columnsDailyBudgetSnapshot.put("remainingToday", new TableInfo.Column("remainingToday", "INTEGER", true, 0, null, TableInfo.CREATED_FROM_ENTITY));
        final HashSet<TableInfo.ForeignKey> _foreignKeysDailyBudgetSnapshot = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesDailyBudgetSnapshot = new HashSet<TableInfo.Index>(1);
        _indicesDailyBudgetSnapshot.add(new TableInfo.Index("index_daily_budget_snapshot_periodId_date", true, Arrays.asList("periodId", "date"), Arrays.asList("ASC", "ASC")));
        final TableInfo _infoDailyBudgetSnapshot = new TableInfo("daily_budget_snapshot", _columnsDailyBudgetSnapshot, _foreignKeysDailyBudgetSnapshot, _indicesDailyBudgetSnapshot);
        final TableInfo _existingDailyBudgetSnapshot = TableInfo.read(db, "daily_budget_snapshot");
        if (!_infoDailyBudgetSnapshot.equals(_existingDailyBudgetSnapshot)) {
          return new RoomOpenHelper.ValidationResult(false, "daily_budget_snapshot(com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity).\n"
                  + " Expected:\n" + _infoDailyBudgetSnapshot + "\n"
                  + " Found:\n" + _existingDailyBudgetSnapshot);
        }
        return new RoomOpenHelper.ValidationResult(true, null);
      }
    }, "251a04abfd905c9ef40a8a69f75a9c36", "2fbbb5ad3d272b8119ec2853b6205b7f");
    final SupportSQLiteOpenHelper.Configuration _sqliteConfig = SupportSQLiteOpenHelper.Configuration.builder(config.context).name(config.name).callback(_openCallback).build();
    final SupportSQLiteOpenHelper _helper = config.sqliteOpenHelperFactory.create(_sqliteConfig);
    return _helper;
  }

  @Override
  @NonNull
  protected InvalidationTracker createInvalidationTracker() {
    final HashMap<String, String> _shadowTablesMap = new HashMap<String, String>(0);
    final HashMap<String, Set<String>> _viewTables = new HashMap<String, Set<String>>(0);
    return new InvalidationTracker(this, _shadowTablesMap, _viewTables, "budget_period","income_source","fixed_expense","expense_transaction","saving_target","saving_allocation","daily_budget_snapshot");
  }

  @Override
  public void clearAllTables() {
    super.assertNotMainThread();
    final SupportSQLiteDatabase _db = super.getOpenHelper().getWritableDatabase();
    try {
      super.beginTransaction();
      _db.execSQL("DELETE FROM `budget_period`");
      _db.execSQL("DELETE FROM `income_source`");
      _db.execSQL("DELETE FROM `fixed_expense`");
      _db.execSQL("DELETE FROM `expense_transaction`");
      _db.execSQL("DELETE FROM `saving_target`");
      _db.execSQL("DELETE FROM `saving_allocation`");
      _db.execSQL("DELETE FROM `daily_budget_snapshot`");
      super.setTransactionSuccessful();
    } finally {
      super.endTransaction();
      _db.query("PRAGMA wal_checkpoint(FULL)").close();
      if (!_db.inTransaction()) {
        _db.execSQL("VACUUM");
      }
    }
  }

  @Override
  @NonNull
  protected Map<Class<?>, List<Class<?>>> getRequiredTypeConverters() {
    final HashMap<Class<?>, List<Class<?>>> _typeConvertersMap = new HashMap<Class<?>, List<Class<?>>>();
    _typeConvertersMap.put(BudgetPeriodDao.class, BudgetPeriodDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(IncomeSourceDao.class, IncomeSourceDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(FixedExpenseDao.class, FixedExpenseDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(ExpenseTransactionDao.class, ExpenseTransactionDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(SavingTargetDao.class, SavingTargetDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(SavingAllocationDao.class, SavingAllocationDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(DailyBudgetSnapshotDao.class, DailyBudgetSnapshotDao_Impl.getRequiredConverters());
    _typeConvertersMap.put(BackupRestoreDao.class, BackupRestoreDao_Impl.getRequiredConverters());
    return _typeConvertersMap;
  }

  @Override
  @NonNull
  public Set<Class<? extends AutoMigrationSpec>> getRequiredAutoMigrationSpecs() {
    final HashSet<Class<? extends AutoMigrationSpec>> _autoMigrationSpecsSet = new HashSet<Class<? extends AutoMigrationSpec>>();
    return _autoMigrationSpecsSet;
  }

  @Override
  @NonNull
  public List<Migration> getAutoMigrations(
      @NonNull final Map<Class<? extends AutoMigrationSpec>, AutoMigrationSpec> autoMigrationSpecs) {
    final List<Migration> _autoMigrations = new ArrayList<Migration>();
    return _autoMigrations;
  }

  @Override
  public BudgetPeriodDao budgetPeriodDao() {
    if (_budgetPeriodDao != null) {
      return _budgetPeriodDao;
    } else {
      synchronized(this) {
        if(_budgetPeriodDao == null) {
          _budgetPeriodDao = new BudgetPeriodDao_Impl(this);
        }
        return _budgetPeriodDao;
      }
    }
  }

  @Override
  public IncomeSourceDao incomeSourceDao() {
    if (_incomeSourceDao != null) {
      return _incomeSourceDao;
    } else {
      synchronized(this) {
        if(_incomeSourceDao == null) {
          _incomeSourceDao = new IncomeSourceDao_Impl(this);
        }
        return _incomeSourceDao;
      }
    }
  }

  @Override
  public FixedExpenseDao fixedExpenseDao() {
    if (_fixedExpenseDao != null) {
      return _fixedExpenseDao;
    } else {
      synchronized(this) {
        if(_fixedExpenseDao == null) {
          _fixedExpenseDao = new FixedExpenseDao_Impl(this);
        }
        return _fixedExpenseDao;
      }
    }
  }

  @Override
  public ExpenseTransactionDao expenseTransactionDao() {
    if (_expenseTransactionDao != null) {
      return _expenseTransactionDao;
    } else {
      synchronized(this) {
        if(_expenseTransactionDao == null) {
          _expenseTransactionDao = new ExpenseTransactionDao_Impl(this);
        }
        return _expenseTransactionDao;
      }
    }
  }

  @Override
  public SavingTargetDao savingTargetDao() {
    if (_savingTargetDao != null) {
      return _savingTargetDao;
    } else {
      synchronized(this) {
        if(_savingTargetDao == null) {
          _savingTargetDao = new SavingTargetDao_Impl(this);
        }
        return _savingTargetDao;
      }
    }
  }

  @Override
  public SavingAllocationDao savingAllocationDao() {
    if (_savingAllocationDao != null) {
      return _savingAllocationDao;
    } else {
      synchronized(this) {
        if(_savingAllocationDao == null) {
          _savingAllocationDao = new SavingAllocationDao_Impl(this);
        }
        return _savingAllocationDao;
      }
    }
  }

  @Override
  public DailyBudgetSnapshotDao dailyBudgetSnapshotDao() {
    if (_dailyBudgetSnapshotDao != null) {
      return _dailyBudgetSnapshotDao;
    } else {
      synchronized(this) {
        if(_dailyBudgetSnapshotDao == null) {
          _dailyBudgetSnapshotDao = new DailyBudgetSnapshotDao_Impl(this);
        }
        return _dailyBudgetSnapshotDao;
      }
    }
  }

  @Override
  public BackupRestoreDao backupRestoreDao() {
    if (_backupRestoreDao != null) {
      return _backupRestoreDao;
    } else {
      synchronized(this) {
        if(_backupRestoreDao == null) {
          _backupRestoreDao = new BackupRestoreDao_Impl(this);
        }
        return _backupRestoreDao;
      }
    }
  }
}
