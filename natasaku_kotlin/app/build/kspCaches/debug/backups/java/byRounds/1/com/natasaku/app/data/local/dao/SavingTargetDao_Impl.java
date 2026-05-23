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
import com.natasaku.app.data.local.entity.SavingTargetEntity;
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
public final class SavingTargetDao_Impl implements SavingTargetDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<SavingTargetEntity> __insertionAdapterOfSavingTargetEntity;

  public SavingTargetDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfSavingTargetEntity = new EntityInsertionAdapter<SavingTargetEntity>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `saving_target` (`id`,`periodId`,`targetAmount`) VALUES (?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final SavingTargetEntity entity) {
        statement.bindString(1, entity.getId());
        statement.bindString(2, entity.getPeriodId());
        statement.bindLong(3, entity.getTargetAmount());
      }
    };
  }

  @Override
  public Object upsert(final SavingTargetEntity target,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfSavingTargetEntity.insert(target);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object upsertAll(final List<SavingTargetEntity> items,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfSavingTargetEntity.insert(items);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Flow<List<SavingTargetEntity>> observeAll() {
    final String _sql = "SELECT * FROM saving_target";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"saving_target"}, new Callable<List<SavingTargetEntity>>() {
      @Override
      @NonNull
      public List<SavingTargetEntity> call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfTargetAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "targetAmount");
          final List<SavingTargetEntity> _result = new ArrayList<SavingTargetEntity>(_cursor.getCount());
          while (_cursor.moveToNext()) {
            final SavingTargetEntity _item;
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final long _tmpTargetAmount;
            _tmpTargetAmount = _cursor.getLong(_cursorIndexOfTargetAmount);
            _item = new SavingTargetEntity(_tmpId,_tmpPeriodId,_tmpTargetAmount);
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
  public Flow<SavingTargetEntity> observeByPeriod(final String periodId) {
    final String _sql = "SELECT * FROM saving_target WHERE periodId = ? LIMIT 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, periodId);
    return CoroutinesRoom.createFlow(__db, false, new String[] {"saving_target"}, new Callable<SavingTargetEntity>() {
      @Override
      @Nullable
      public SavingTargetEntity call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfPeriodId = CursorUtil.getColumnIndexOrThrow(_cursor, "periodId");
          final int _cursorIndexOfTargetAmount = CursorUtil.getColumnIndexOrThrow(_cursor, "targetAmount");
          final SavingTargetEntity _result;
          if (_cursor.moveToFirst()) {
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpPeriodId;
            _tmpPeriodId = _cursor.getString(_cursorIndexOfPeriodId);
            final long _tmpTargetAmount;
            _tmpTargetAmount = _cursor.getLong(_cursorIndexOfTargetAmount);
            _result = new SavingTargetEntity(_tmpId,_tmpPeriodId,_tmpTargetAmount);
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
