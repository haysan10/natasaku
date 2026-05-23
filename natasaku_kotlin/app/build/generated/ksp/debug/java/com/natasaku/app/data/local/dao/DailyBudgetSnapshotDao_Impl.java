package com.natasaku.app.data.local.dao;

import android.database.Cursor;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.natasaku.app.data.local.database.RoomConverters;
import com.natasaku.app.data.local.entity.DailyBudgetSnapshotEntity;
import java.lang.Class;
import java.lang.Exception;
import java.lang.IllegalStateException;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlinx.coroutines.flow.Flow;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class DailyBudgetSnapshotDao_Impl implements DailyBudgetSnapshotDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<DailyBudgetSnapshotEntity> __insertionAdapterOfDailyBudgetSnapshotEntity;

  private final RoomConverters __roomConverters = new RoomConverters();

  public DailyBudgetSnapshotDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfDailyBudgetSnapshotEntity = new EntityInsertionAdapter<DailyBudgetSnapshotEntity>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `daily_budget_snapshot` (`id`,`periodId`,`date`,`finalDailyAllowance`,`spentToday`,`remainingToday`) VALUES (?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final DailyBudgetSnapshotEntity entity) {
        statement.bindString(1, entity.getId());
        statement.bindString(2, entity.getPeriodId());
        final String _tmp = __roomConverters.localDateToString(entity.getDate());
        if (_tmp == null) {
          statement.bindNull(3);
        } else {
          statement.bindString(3, _tmp);
        }
        statement.bindLong(4, entity.getFinalDailyAllowance());
        statement.bindLong(5, entity.getSpentToday());
        statement.bindLong(6, entity.getRemainingToday());
      }
    };
  }

  @Override
  public Object upsert(final DailyBudgetSnapshotEntity snapshot,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfDailyBudgetSnapshotEntity.insert(snapshot);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object upsertAll(final List<DailyBudgetSnapshotEntity> items,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfDailyBudgetSnapshotEntity.insert(items);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Flow<List<DailyBudgetSnapshotEntity>> observeAll() {
    final String _sql = "SELECT * FROM daily_budget_snapshot ORDER BY date DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"daily_budget_snapshot"}, new Callable<List<DailyBudgetSnapshotEntity>>() {
      @Override
      @NonNull
      public List<DailyBudgetSnapshotEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfFinalDailyAllowance = CursorUtil.getColumnIndexOrThrow(_cursor, "finalDailyAllowance");
          final int _cursorIndexOfSpentToday = CursorUtil.getColumnIndexOrThrow(_cursor, "spentToday");
          final int _cursorIndexOfRemainingToday = CursorUtil.getColumnIndexOrThrow(_cursor, "remainingToday");
          final List<DailyBudgetSnapshotEntity> _result = new ArrayList<DailyBudgetSnapshotEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final DailyBudgetSnapshotEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final LocalDate _tmpDate;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfDate)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfDate);
            }
            final LocalDate _tmp_1 = __roomConverters.stringToLocalDate(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.LocalDate', but it was NULL.");
            } else {
              _tmpDate = _tmp_1;
            }
            final long _tmpFinalDailyAllowance;
            _tmpFinalDailyAllowance = _cursor.getLong(_cursorIndexOfFinalDailyAllowance);
            final long _tmpSpentToday;
            _tmpSpentToday = _cursor.getLong(_cursorIndexOfSpentToday);
            final long _tmpRemainingToday;
            _tmpRemainingToday = _cursor.getLong(_cursorIndexOfRemainingToday);
            _item = new DailyBudgetSnapshotEntity(_tmpId,_tmpPeriodId,_tmpDate,_tmpFinalDailyAllowance,_tmpSpentToday,_tmpRemainingToday);
            _result.add(_item);
          }
          return _result;
        } finally {
          _cursor.close();
        }
      }

      @Override
      protected void finalize() {
        _statement.release();
      }
    });
  }

  @Override
  public Flow<DailyBudgetSnapshotEntity> observeByDate(final String periodId,
      final LocalDate date) {
    final String _sql = "SELECT * FROM daily_budget_snapshot WHERE periodId = ? AND date = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 2);
    int _argIndex = 1;
    _statement.bindString(_argIndex, periodId);
    _argIndex = 2;
    final String _tmp = __roomConverters.localDateToString(date);
    if (_tmp == null) {
      _statement.bindNull(_argIndex);
    } else {
      _statement.bindString(_argIndex, _tmp);
    }
    return CoroutinesRoom.createFlow(__db, false, new String[] {"daily_budget_snapshot"}, new Callable<DailyBudgetSnapshotEntity>() {
      @Override
      @Nullable
      public DailyBudgetSnapshotEntity call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfFinalDailyAllowance = CursorUtil.getColumnIndexOrThrow(_cursor, "finalDailyAllowance");
          final int _cursorIndexOfSpentToday = CursorUtil.getColumnIndexOrThrow(_cursor, "spentToday");
          final int _cursorIndexOfRemainingToday = CursorUtil.getColumnIndexOrThrow(_cursor, "remainingToday");
          final DailyBudgetSnapshotEntity _result;
          if (_cursor.moveToFirst()) {
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final LocalDate _tmpDate;
            final String _tmp_1;
            if (_cursor.isNull(_cursorIndexOfDate)) {
              _tmp_1 = null;
            } else {
              _tmp_1 = _cursor.getString(_cursorIndexOfDate);
            }
            final LocalDate _tmp_2 = __roomConverters.stringToLocalDate(_tmp_1);
            if (_tmp_2 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.LocalDate', but it was NULL.");
            } else {
              _tmpDate = _tmp_2;
            }
            final long _tmpFinalDailyAllowance;
            _tmpFinalDailyAllowance = _cursor.getLong(_cursorIndexOfFinalDailyAllowance);
            final long _tmpSpentToday;
            _tmpSpentToday = _cursor.getLong(_cursorIndexOfSpentToday);
            final long _tmpRemainingToday;
            _tmpRemainingToday = _cursor.getLong(_cursorIndexOfRemainingToday);
            _result = new DailyBudgetSnapshotEntity(_tmpId,_tmpPeriodId,_tmpDate,_tmpFinalDailyAllowance,_tmpSpentToday,_tmpRemainingToday);
          } else {
            _result = null;
          }
          return _result;
        } finally {
          _cursor.close();
        }
      }

      @Override
      protected void finalize() {
        _statement.release();
      }
    });
  }

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
