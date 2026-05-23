package com.natasaku.app.data.local.dao;

import android.database.Cursor;
import androidx.annotation.NonNull;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import com.natasaku.app.data.local.entity.IncomeSourceEntity;
import java.lang.Class;
import java.lang.Exception;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
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
public final class IncomeSourceDao_Impl implements IncomeSourceDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<IncomeSourceEntity> __insertionAdapterOfIncomeSourceEntity;

  public IncomeSourceDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfIncomeSourceEntity = new EntityInsertionAdapter<IncomeSourceEntity>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `income_source` (`id`,`periodId`,`name`,`amount`) VALUES (?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final IncomeSourceEntity entity) {
        statement.bindString(1, entity.getId());
        statement.bindString(2, entity.getPeriodId());
        statement.bindString(3, entity.getName());
        statement.bindLong(4, entity.getAmount());
      }
    };
  }

  @Override
  public Object upsertAll(final List<IncomeSourceEntity> items,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfIncomeSourceEntity.insert(items);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Flow<List<IncomeSourceEntity>> observeAll() {
    final String _sql = "SELECT * FROM income_source";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"income_source"}, new Callable<List<IncomeSourceEntity>>() {
      @Override
      @NonNull
      public List<IncomeSourceEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final List<IncomeSourceEntity> _result = new ArrayList<IncomeSourceEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final IncomeSourceEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            _item = new IncomeSourceEntity(_tmpId,_tmpPeriodId,_tmpName,_tmpAmount);
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
  public Flow<List<IncomeSourceEntity>> observeByPeriod(final String periodId) {
    final String _sql = "SELECT * FROM income_source WHERE periodId = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, periodId);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"income_source"}, new Callable<List<IncomeSourceEntity>>() {
      @Override
      @NonNull
      public List<IncomeSourceEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfName = CursorUtil.getColumnIndexOrThrow(_cursor, "name");
          final int _cursorIndexOfAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "amount");
          final List<IncomeSourceEntity> _result = new ArrayList<IncomeSourceEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final IncomeSourceEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final String _tmpName;
            _tmpName = _cursor.getString(_cursorIndexOfName);
            final long _tmpAmount;
            _tmpAmount = _cursor.getLong(_cursorIndexOfAmount);
            _item = new IncomeSourceEntity(_tmpId,_tmpPeriodId,_tmpName,_tmpAmount);
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
