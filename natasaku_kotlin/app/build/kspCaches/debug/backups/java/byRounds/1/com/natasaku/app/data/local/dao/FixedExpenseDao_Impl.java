package com.natasaku.app.data.local.dao;

import android.database.Cursor;
import android.os.CancellationSignal;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.SharedSQLiteStatement;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.natasaku.app.data.local.database.RoomConverters;
import com.natasaku.app.data.local.entity.FixedExpenseEntity;
import com.natasaku.app.domain.model.FixedExpenseStatus;
import java.lang.Class;
import java.lang.Exception;
import java.lang.IllegalStateException;
import java.lang.Long;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.time.Instant;
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
public final class FixedExpenseDao_Impl implements FixedExpenseDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<FixedExpenseEntity> __insertionAdapterOfFixedExpenseEntity;

  private final RoomConverters __roomConverters = new RoomConverters();

  private final SharedSQLiteStatement __preparedStmtOfUpdatePaid;

  private final SharedSQLiteStatement __preparedStmtOfUpdateSnooze;

  private final SharedSQLiteStatement __preparedStmtOfReschedule;

  private final SharedSQLiteStatement __preparedStmtOfUpdateStatus;

  public FixedExpenseDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfFixedExpenseEntity = new EntityInsertionAdapter<FixedExpenseEntity>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `fixed_expense` (`id`,`periodId`,`name`,`amount`,`dueDay`,`status`,`snoozedUntilTs`,`paidAt`,`createdAt`) VALUES (?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final FixedExpenseEntity entity) {
        statement.bindString(1, entity.getId());
        statement.bindString(2, entity.getPeriodId());
        statement.bindString(3, entity.getName());
        statement.bindLong(4, entity.getAmount());
        statement.bindLong(5, entity.getDueDay());
        final String _tmp = __roomConverters.fixedExpenseStatusToString(entity.getStatus());
        if (_tmp == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, _tmp);
        }
        final Long _tmp_1 = __roomConverters.instantToEpochMillis(entity.getSnoozedUntilTs());
        if (_tmp_1 == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, _tmp_1);
        }
        final Long _tmp_2 = __roomConverters.instantToEpochMillis(entity.getPaidAt());
        if (_tmp_2 == null) {
          statement.bindNull(8);
        } else {
          statement.bindLong(8, _tmp_2);
        }
        final Long _tmp_3 = __roomConverters.instantToEpochMillis(entity.getCreatedAt());
        if (_tmp_3 == null) {
          statement.bindNull(9);
        } else {
          statement.bindLong(9, _tmp_3);
        }
      }
    };
    this.__preparedStmtOfUpdatePaid = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "UPDATE fixed_expense SET status = ?, paidAt = ?, snoozedUntilTs = NULL WHERE id = ?";
        return _query;
      }
    };
    this.__preparedStmtOfUpdateSnooze = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "UPDATE fixed_expense SET status = ?, snoozedUntilTs = ? WHERE id = ?";
        return _query;
      }
    };
    this.__preparedStmtOfReschedule = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "UPDATE fixed_expense SET status = ?, dueDay = ?, snoozedUntilTs = NULL WHERE id = ?";
        return _query;
      }
    };
    this.__preparedStmtOfUpdateStatus = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "UPDATE fixed_expense SET status = ? WHERE id = ?";
        return _query;
      }
    };
  }

  @Override
  public Object upsert(final FixedExpenseEntity item,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfFixedExpenseEntity.insert(item);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object upsertAll(final List<FixedExpenseEntity> items,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfFixedExpenseEntity.insert(items);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object updatePaid(final String id, final FixedExpenseStatus status, final Instant paidAt,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfUpdatePaid.acquire();
        int _argIndex = 1;
        final String _tmp = __roomConverters.fixedExpenseStatusToString(status);
        if (_tmp == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindString(_argIndex, _tmp);
        }
        _argIndex = 2;
        final Long _tmp_1 = __roomConverters.instantToEpochMillis(paidAt);
        if (_tmp_1 == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindLong(_argIndex, _tmp_1);
        }
        _argIndex = 3;
        _stmt.bindString(_argIndex, id);
        try {
          __db.beginTransaction();
          try {
            _stmt.executeUpdateDelete();
            __db.setTransactionSuccessful();
            return Unit.INSTANCE;
          } finally {
            __db.endTransaction();
          }
        } finally {
          __preparedStmtOfUpdatePaid.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public Object updateSnooze(final String id, final FixedExpenseStatus status,
      final Instant snoozedUntilTs, final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfUpdateSnooze.acquire();
        int _argIndex = 1;
        final String _tmp = __roomConverters.fixedExpenseStatusToString(status);
        if (_tmp == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindString(_argIndex, _tmp);
        }
        _argIndex = 2;
        final Long _tmp_1 = __roomConverters.instantToEpochMillis(snoozedUntilTs);
        if (_tmp_1 == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindLong(_argIndex, _tmp_1);
        }
        _argIndex = 3;
        _stmt.bindString(_argIndex, id);
        try {
          __db.beginTransaction();
          try {
            _stmt.executeUpdateDelete();
            __db.setTransactionSuccessful();
            return Unit.INSTANCE;
          } finally {
            __db.endTransaction();
          }
        } finally {
          __preparedStmtOfUpdateSnooze.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public Object reschedule(final String id, final FixedExpenseStatus status, final int dueDay,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfReschedule.acquire();
        int _argIndex = 1;
        final String _tmp = __roomConverters.fixedExpenseStatusToString(status);
        if (_tmp == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindString(_argIndex, _tmp);
        }
        _argIndex = 2;
        _stmt.bindLong(_argIndex, dueDay);
        _argIndex = 3;
        _stmt.bindString(_argIndex, id);
        try {
          __db.beginTransaction();
          try {
            _stmt.executeUpdateDelete();
            __db.setTransactionSuccessful();
            return Unit.INSTANCE;
          } finally {
            __db.endTransaction();
          }
        } finally {
          __preparedStmtOfReschedule.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public Object updateStatus(final String id, final FixedExpenseStatus status,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfUpdateStatus.acquire();
        int _argIndex = 1;
        final String _tmp = __roomConverters.fixedExpenseStatusToString(status);
        if (_tmp == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindString(_argIndex, _tmp);
        }
        _argIndex = 2;
        _stmt.bindString(_argIndex, id);
        try {
          __db.beginTransaction();
          try {
            _stmt.executeUpdateDelete();
            __db.setTransactionSuccessful();
            return Unit.INSTANCE;
          } finally {
            __db.endTransaction();
          }
        } finally {
          __preparedStmtOfUpdateStatus.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public Flow<List<FixedExpenseEntity>> observeAll() {
    final String _sql = "SELECT * FROM fixed_expense";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"fixed_expense"}, new Callable<List<FixedExpenseEntity>>() {
      @Override
      @NonNull
      public List<FixedExpenseEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final int _cursorIndexOfDueDay = CursorUtil.getColumnIndexOrThrow(_cursor, "dueDay");
          final int _cursorIndexOfStatus = CursorUtil.getColumnIndexOrThrow(_cursor, "status");
          final int _cursorIndexOfSnoozedUntilTs = CursorUtil.getColumnIndexOrThrow(_cursor, "snoozedUntilTs");
          final int _cursorIndexOfPaidAt = CursorUtil.getColumnIndexOrThrow(_cursor, "paidAt");
          final int _cursorIndexOfCreatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "createdAt");
          final List<FixedExpenseEntity> _result = new ArrayList<FixedExpenseEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final FixedExpenseEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            final int _tmpDueDay;
            _tmpDueDay = _cursor.getInt(_cursorIndexOfDueDay);
            final FixedExpenseStatus _tmpStatus;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfStatus)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfStatus);
            }
            final FixedExpenseStatus _tmp_1 = __roomConverters.stringToFixedExpenseStatus(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'com.natasaku.app.domain.model.FixedExpenseStatus', but it was NULL.");
            } else {
              _tmpStatus = _tmp_1;
            }
            final Instant _tmpSnoozedUntilTs;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfSnoozedUntilTs)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfSnoozedUntilTs);
            }
            _tmpSnoozedUntilTs = __roomConverters.epochMillisToInstant(_tmp_2);
            final Instant _tmpPaidAt;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfPaidAt)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfPaidAt);
            }
            _tmpPaidAt = __roomConverters.epochMillisToInstant(_tmp_3);
            final Instant _tmpCreatedAt;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfCreatedAt)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfCreatedAt);
            }
            final Instant _tmp_5 = __roomConverters.epochMillisToInstant(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpCreatedAt = _tmp_5;
            }
            _item = new FixedExpenseEntity(_tmpId,_tmpPeriodId,_tmpName,_tmpAmount,_tmpDueDay,_tmpStatus,_tmpSnoozedUntilTs,_tmpPaidAt,_tmpCreatedAt);
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
  public Flow<List<FixedExpenseEntity>> observeByPeriod(final String periodId) {
    final String _sql = "SELECT * FROM fixed_expense WHERE periodId = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, periodId);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"fixed_expense"}, new Callable<List<FixedExpenseEntity>>() {
      @Override
      @NonNull
      public List<FixedExpenseEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final int _cursorIndexOfDueDay = CursorUtil.getColumnIndexOrThrow(_cursor, "dueDay");
          final int _cursorIndexOfStatus = CursorUtil.getColumnIndexOrThrow(_cursor, "status");
          final int _cursorIndexOfSnoozedUntilTs = CursorUtil.getColumnIndexOrThrow(_cursor, "snoozedUntilTs");
          final int _cursorIndexOfPaidAt = CursorUtil.getColumnIndexOrThrow(_cursor, "paidAt");
          final int _cursorIndexOfCreatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "createdAt");
          final List<FixedExpenseEntity> _result = new ArrayList<FixedExpenseEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final FixedExpenseEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            final int _tmpDueDay;
            _tmpDueDay = _cursor.getInt(_cursorIndexOfDueDay);
            final FixedExpenseStatus _tmpStatus;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfStatus)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfStatus);
            }
            final FixedExpenseStatus _tmp_1 = __roomConverters.stringToFixedExpenseStatus(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'com.natasaku.app.domain.model.FixedExpenseStatus', but it was NULL.");
            } else {
              _tmpStatus = _tmp_1;
            }
            final Instant _tmpSnoozedUntilTs;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfSnoozedUntilTs)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfSnoozedUntilTs);
            }
            _tmpSnoozedUntilTs = __roomConverters.epochMillisToInstant(_tmp_2);
            final Instant _tmpPaidAt;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfPaidAt)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfPaidAt);
            }
            _tmpPaidAt = __roomConverters.epochMillisToInstant(_tmp_3);
            final Instant _tmpCreatedAt;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfCreatedAt)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfCreatedAt);
            }
            final Instant _tmp_5 = __roomConverters.epochMillisToInstant(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpCreatedAt = _tmp_5;
            }
            _item = new FixedExpenseEntity(_tmpId,_tmpPeriodId,_tmpName,_tmpAmount,_tmpDueDay,_tmpStatus,_tmpSnoozedUntilTs,_tmpPaidAt,_tmpCreatedAt);
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
  public Object getById(final String id,
      final Continuation<? super FixedExpenseEntity> $completion) {
    final String _sql = "SELECT * FROM fixed_expense WHERE id = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, id);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<FixedExpenseEntity>() {
      @Override
      @Nullable
      public FixedExpenseEntity call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final int _cursorIndexOfDueDay = CursorUtil.getColumnIndexOrThrow(_cursor, "dueDay");
          final int _cursorIndexOfStatus = CursorUtil.getColumnIndexOrThrow(_cursor, "status");
          final int _cursorIndexOfSnoozedUntilTs = CursorUtil.getColumnIndexOrThrow(_cursor, "snoozedUntilTs");
          final int _cursorIndexOfPaidAt = CursorUtil.getColumnIndexOrThrow(_cursor, "paidAt");
          final int _cursorIndexOfCreatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "createdAt");
          final FixedExpenseEntity _result;
          if (_cursor.moveToFirst()) {
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            final int _tmpDueDay;
            _tmpDueDay = _cursor.getInt(_cursorIndexOfDueDay);
            final FixedExpenseStatus _tmpStatus;
            final String _tmp;
            if (_cursor.isNull(_cursorIndexOfStatus)) {
              _tmp = null;
            } else {
              _tmp = _cursor.getString(_cursorIndexOfStatus);
            }
            final FixedExpenseStatus _tmp_1 = __roomConverters.stringToFixedExpenseStatus(_tmp);
            if (_tmp_1 == null) {
              throw new IllegalStateException("Expected NON-NULL 'com.natasaku.app.domain.model.FixedExpenseStatus', but it was NULL.");
            } else {
              _tmpStatus = _tmp_1;
            }
            final Instant _tmpSnoozedUntilTs;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfSnoozedUntilTs)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfSnoozedUntilTs);
            }
            _tmpSnoozedUntilTs = __roomConverters.epochMillisToInstant(_tmp_2);
            final Instant _tmpPaidAt;
            final Long _tmp_3;
            if (_cursor.isNull(_cursorIndexOfPaidAt)) {
              _tmp_3 = null;
            } else {
              _tmp_3 = _cursor.getLong(_cursorIndexOfPaidAt);
            }
            _tmpPaidAt = __roomConverters.epochMillisToInstant(_tmp_3);
            final Instant _tmpCreatedAt;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfCreatedAt)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfCreatedAt);
            }
            final Instant _tmp_5 = __roomConverters.epochMillisToInstant(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpCreatedAt = _tmp_5;
            }
            _result = new FixedExpenseEntity(_tmpId,_tmpPeriodId,_tmpName,_tmpAmount,_tmpDueDay,_tmpStatus,_tmpSnoozedUntilTs,_tmpPaidAt,_tmpCreatedAt);
          } else {
            _result = null;
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
