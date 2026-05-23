package com.natasaku.app.data.local.dao;

import android.database.Cursor;
import androidx.annotation.NonNull;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.SharedSQLiteStatement;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.natasaku.app.data.local.database.RoomConverters;
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity;
import com.natasaku.app.domain.model.ExpenseSource;
import java.lang.Class;
import java.lang.Exception;
import java.lang.IllegalStateException;
import java.lang.Long;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.time.Instant;
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
public final class ExpenseTransactionDao_Impl implements ExpenseTransactionDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<ExpenseTransactionEntity> __insertionAdapterOfExpenseTransactionEntity;

  private final RoomConverters __roomConverters = new RoomConverters();

  private final SharedSQLiteStatement __preparedStmtOfSoftDelete;

  public ExpenseTransactionDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfExpenseTransactionEntity = new EntityInsertionAdapter<ExpenseTransactionEntity>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `expense_transaction` (`id`,`periodId`,`amount`,`category`,`date`,`note`,`createdAt`,`updatedAt`,`deletedAt`,`source`,`fixedExpenseId`) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final ExpenseTransactionEntity entity) {
        statement.bindString(1, entity.getId());
        statement.bindString(2, entity.getPeriodId());
        statement.bindLong(3, entity.getAmount());
        statement.bindString(4, entity.getCategory());
        final String _tmp = __roomConverters.localDateToString(entity.getDate());
        if (_tmp == null) {
          statement.bindNull(5);
        } else {
          statement.bindString(5, _tmp);
        }
        if (entity.getNote() == null) {
          statement.bindNull(6);
        } else {
          statement.bindString(6, entity.getNote());
        }
        final Long _tmp_1 = __roomConverters.instantToEpochMillis(entity.getCreatedAt());
        if (_tmp_1 == null) {
          statement.bindNull(7);
        } else {
          statement.bindLong(7, _tmp_1);
        }
        final Long _tmp_2 = __roomConverters.instantToEpochMillis(entity.getUpdatedAt());
        if (_tmp_2 == null) {
          statement.bindNull(8);
        } else {
          statement.bindLong(8, _tmp_2);
        }
        final Long _tmp_3 = __roomConverters.instantToEpochMillis(entity.getDeletedAt());
        if (_tmp_3 == null) {
          statement.bindNull(9);
        } else {
          statement.bindLong(9, _tmp_3);
        }
        final String _tmp_4 = __roomConverters.expenseSourceToString(entity.getSource());
        if (_tmp_4 == null) {
          statement.bindNull(10);
        } else {
          statement.bindString(10, _tmp_4);
        }
        if (entity.getFixedExpenseId() == null) {
          statement.bindNull(11);
        } else {
          statement.bindString(11, entity.getFixedExpenseId());
        }
      }
    };
    this.__preparedStmtOfSoftDelete = new SharedSQLiteStatement(__db) {
      @Override
      @NonNull
      public String createQuery() {
        final String _query = "UPDATE expense_transaction SET deletedAt = ? WHERE id = ?";
        return _query;
      }
    };
  }

  @Override
  public Object upsert(final ExpenseTransactionEntity transaction,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfExpenseTransactionEntity.insert(transaction);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object upsertAll(final List<ExpenseTransactionEntity> items,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfExpenseTransactionEntity.insert(items);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object softDelete(final String id, final Instant deletedAt,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        final SupportSQLiteStatement _stmt = __preparedStmtOfSoftDelete.acquire();
        int _argIndex = 1;
        final Long _tmp = __roomConverters.instantToEpochMillis(deletedAt);
        if (_tmp == null) {
          _stmt.bindNull(_argIndex);
        } else {
          _stmt.bindLong(_argIndex, _tmp);
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
          __preparedStmtOfSoftDelete.release(_stmt);
        }
      }
    }, $completion);
  }

  @Override
  public Flow<List<ExpenseTransactionEntity>> observeAll() {
    final String _sql = "SELECT * FROM expense_transaction ORDER BY date DESC, createdAt DESC";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"expense_transaction"}, new Callable<List<ExpenseTransactionEntity>>() {
      @Override
      @NonNull
      public List<ExpenseTransactionEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfNote = CursorUtil.getColumnIndexOrThrow(_cursor, "note");
          final int _cursorIndexOfCreatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "createdAt");
          final int _cursorIndexOfUpdatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "updatedAt");
          final int _cursorIndexOfDeletedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "deletedAt");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfFixedExpenseId = CursorUtil.getColumnIndexOrThrow(_cursor, "fixedExpenseId");
          final List<ExpenseTransactionEntity> _result = new ArrayList<ExpenseTransactionEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final ExpenseTransactionEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
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
            final String _tmpNote;
            if (_cursor.isNull(_cursorIndexOfNote)) {
              _tmpNote = null;
            } else {
              _tmpNote = _cursor.getString(_cursorIndexOfNote);
            }
            final Instant _tmpCreatedAt;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfCreatedAt)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfCreatedAt);
            }
            final Instant _tmp_3 = __roomConverters.epochMillisToInstant(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpCreatedAt = _tmp_3;
            }
            final Instant _tmpUpdatedAt;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfUpdatedAt)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfUpdatedAt);
            }
            final Instant _tmp_5 = __roomConverters.epochMillisToInstant(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpUpdatedAt = _tmp_5;
            }
            final Instant _tmpDeletedAt;
            final Long _tmp_6;
            if (_cursor.isNull(_cursorIndexOfDeletedAt)) {
              _tmp_6 = null;
            } else {
              _tmp_6 = _cursor.getLong(_cursorIndexOfDeletedAt);
            }
            _tmpDeletedAt = __roomConverters.epochMillisToInstant(_tmp_6);
            final ExpenseSource _tmpSource;
            final String _tmp_7;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmp_7 = null;
            } else {
              _tmp_7 = _cursor.getString(_cursorIndexOfSource);
            }
            final ExpenseSource _tmp_8 = __roomConverters.stringToExpenseSource(_tmp_7);
            if (_tmp_8 == null) {
              throw new IllegalStateException("Expected NON-NULL 'com.natasaku.app.domain.model.ExpenseSource', but it was NULL.");
            } else {
              _tmpSource = _tmp_8;
            }
            final String _tmpFixedExpenseId;
            if (_cursor.isNull(_cursorIndexOfFixedExpenseId)) {
              _tmpFixedExpenseId = null;
            } else {
              _tmpFixedExpenseId = _cursor.getString(_cursorIndexOfFixedExpenseId);
            }
            _item = new ExpenseTransactionEntity(_tmpId,_tmpPeriodId,_tmpAmount,_tmpCategory,_tmpDate,_tmpNote,_tmpCreatedAt,_tmpUpdatedAt,_tmpDeletedAt,_tmpSource,_tmpFixedExpenseId);
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
  public Flow<List<ExpenseTransactionEntity>> observeByPeriod(final String periodId) {
    final String _sql = "\n"
            + "        SELECT * FROM expense_transaction\n"
            + "        WHERE periodId = ? AND deletedAt IS NULL\n"
            + "        ORDER BY date DESC, createdAt DESC\n"
            + "    ";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, periodId);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"expense_transaction"}, new Callable<List<ExpenseTransactionEntity>>() {
      @Override
      @NonNull
      public List<ExpenseTransactionEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfNote = CursorUtil.getColumnIndexOrThrow(_cursor, "note");
          final int _cursorIndexOfCreatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "createdAt");
          final int _cursorIndexOfUpdatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "updatedAt");
          final int _cursorIndexOfDeletedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "deletedAt");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfFixedExpenseId = CursorUtil.getColumnIndexOrThrow(_cursor, "fixedExpenseId");
          final List<ExpenseTransactionEntity> _result = new ArrayList<ExpenseTransactionEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final ExpenseTransactionEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
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
            final String _tmpNote;
            if (_cursor.isNull(_cursorIndexOfNote)) {
              _tmpNote = null;
            } else {
              _tmpNote = _cursor.getString(_cursorIndexOfNote);
            }
            final Instant _tmpCreatedAt;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfCreatedAt)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfCreatedAt);
            }
            final Instant _tmp_3 = __roomConverters.epochMillisToInstant(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpCreatedAt = _tmp_3;
            }
            final Instant _tmpUpdatedAt;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfUpdatedAt)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfUpdatedAt);
            }
            final Instant _tmp_5 = __roomConverters.epochMillisToInstant(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpUpdatedAt = _tmp_5;
            }
            final Instant _tmpDeletedAt;
            final Long _tmp_6;
            if (_cursor.isNull(_cursorIndexOfDeletedAt)) {
              _tmp_6 = null;
            } else {
              _tmp_6 = _cursor.getLong(_cursorIndexOfDeletedAt);
            }
            _tmpDeletedAt = __roomConverters.epochMillisToInstant(_tmp_6);
            final ExpenseSource _tmpSource;
            final String _tmp_7;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmp_7 = null;
            } else {
              _tmp_7 = _cursor.getString(_cursorIndexOfSource);
            }
            final ExpenseSource _tmp_8 = __roomConverters.stringToExpenseSource(_tmp_7);
            if (_tmp_8 == null) {
              throw new IllegalStateException("Expected NON-NULL 'com.natasaku.app.domain.model.ExpenseSource', but it was NULL.");
            } else {
              _tmpSource = _tmp_8;
            }
            final String _tmpFixedExpenseId;
            if (_cursor.isNull(_cursorIndexOfFixedExpenseId)) {
              _tmpFixedExpenseId = null;
            } else {
              _tmpFixedExpenseId = _cursor.getString(_cursorIndexOfFixedExpenseId);
            }
            _item = new ExpenseTransactionEntity(_tmpId,_tmpPeriodId,_tmpAmount,_tmpCategory,_tmpDate,_tmpNote,_tmpCreatedAt,_tmpUpdatedAt,_tmpDeletedAt,_tmpSource,_tmpFixedExpenseId);
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
  public Flow<List<ExpenseTransactionEntity>> observeByPeriodAndQuery(final String periodId,
      final String query) {
    final String _sql = "\n"
            + "        SELECT * FROM expense_transaction\n"
            + "        WHERE periodId = ?\n"
            + "        AND deletedAt IS NULL\n"
            + "        AND (? = '' OR category LIKE '%' || ? || '%' OR note LIKE '%' || ? || '%')\n"
            + "        ORDER BY date DESC, createdAt DESC\n"
            + "    ";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 4);
    int _argIndex = 1;
    _statement.bindString(_argIndex, periodId);
    _argIndex = 2;
    _statement.bindString(_argIndex, query);
    _argIndex = 3;
    _statement.bindString(_argIndex, query);
    _argIndex = 4;
    _statement.bindString(_argIndex, query);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"expense_transaction"}, new Callable<List<ExpenseTransactionEntity>>() {
      @Override
      @NonNull
      public List<ExpenseTransactionEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final int _cursorIndexOfCategory = CursorUtil.getColumnIndexOrThrow(_cursor, "category");
          final int _cursorIndexOfDate = CursorUtil.getColumnIndexOrThrow(_cursor, "date");
          final int _cursorIndexOfNote = CursorUtil.getColumnIndexOrThrow(_cursor, "note");
          final int _cursorIndexOfCreatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "createdAt");
          final int _cursorIndexOfUpdatedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "updatedAt");
          final int _cursorIndexOfDeletedAt = CursorUtil.getColumnIndexOrThrow(_cursor, "deletedAt");
          final int _cursorIndexOfSource = CursorUtil.getColumnIndexOrThrow(_cursor, "source");
          final int _cursorIndexOfFixedExpenseId = CursorUtil.getColumnIndexOrThrow(_cursor, "fixedExpenseId");
          final List<ExpenseTransactionEntity> _result = new ArrayList<ExpenseTransactionEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final ExpenseTransactionEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            final String _tmpCategory;
            _tmpCategory = _cursor.getString(_cursorIndexOfCategory);
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
            final String _tmpNote;
            if (_cursor.isNull(_cursorIndexOfNote)) {
              _tmpNote = null;
            } else {
              _tmpNote = _cursor.getString(_cursorIndexOfNote);
            }
            final Instant _tmpCreatedAt;
            final Long _tmp_2;
            if (_cursor.isNull(_cursorIndexOfCreatedAt)) {
              _tmp_2 = null;
            } else {
              _tmp_2 = _cursor.getLong(_cursorIndexOfCreatedAt);
            }
            final Instant _tmp_3 = __roomConverters.epochMillisToInstant(_tmp_2);
            if (_tmp_3 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpCreatedAt = _tmp_3;
            }
            final Instant _tmpUpdatedAt;
            final Long _tmp_4;
            if (_cursor.isNull(_cursorIndexOfUpdatedAt)) {
              _tmp_4 = null;
            } else {
              _tmp_4 = _cursor.getLong(_cursorIndexOfUpdatedAt);
            }
            final Instant _tmp_5 = __roomConverters.epochMillisToInstant(_tmp_4);
            if (_tmp_5 == null) {
              throw new IllegalStateException("Expected NON-NULL 'java.time.Instant', but it was NULL.");
            } else {
              _tmpUpdatedAt = _tmp_5;
            }
            final Instant _tmpDeletedAt;
            final Long _tmp_6;
            if (_cursor.isNull(_cursorIndexOfDeletedAt)) {
              _tmp_6 = null;
            } else {
              _tmp_6 = _cursor.getLong(_cursorIndexOfDeletedAt);
            }
            _tmpDeletedAt = __roomConverters.epochMillisToInstant(_tmp_6);
            final ExpenseSource _tmpSource;
            final String _tmp_7;
            if (_cursor.isNull(_cursorIndexOfSource)) {
              _tmp_7 = null;
            } else {
              _tmp_7 = _cursor.getString(_cursorIndexOfSource);
            }
            final ExpenseSource _tmp_8 = __roomConverters.stringToExpenseSource(_tmp_7);
            if (_tmp_8 == null) {
              throw new IllegalStateException("Expected NON-NULL 'com.natasaku.app.domain.model.ExpenseSource', but it was NULL.");
            } else {
              _tmpSource = _tmp_8;
            }
            final String _tmpFixedExpenseId;
            if (_cursor.isNull(_cursorIndexOfFixedExpenseId)) {
              _tmpFixedExpenseId = null;
            } else {
              _tmpFixedExpenseId = _cursor.getString(_cursorIndexOfFixedExpenseId);
            }
            _item = new ExpenseTransactionEntity(_tmpId,_tmpPeriodId,_tmpAmount,_tmpCategory,_tmpDate,_tmpNote,_tmpCreatedAt,_tmpUpdatedAt,_tmpDeletedAt,_tmpSource,_tmpFixedExpenseId);
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

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
