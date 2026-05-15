package com.natasaku.app.data.local

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import com.natasaku.app.data.local.database.NataSakuDatabase
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import java.time.Instant
import java.time.LocalDate
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ExpenseTransactionDaoTest {
    private lateinit var db: NataSakuDatabase

    @Before
    fun setup() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        db = Room.inMemoryDatabaseBuilder(context, NataSakuDatabase::class.java)
            .allowMainThreadQueries()
            .build()
    }

    @After
    fun tearDown() { db.close() }

    @Test
    fun insert_search_softDelete_workCorrectly() = runBlocking {
        val now = Instant.now()
        val dao = db.expenseTransactionDao()
        dao.upsert(ExpenseTransactionEntity("t1", "p1", 10_000, "Makan", LocalDate.of(2026, 5, 1), "siang", now, now, null))
        dao.upsert(ExpenseTransactionEntity("t2", "p1", 20_000, "Transport", LocalDate.of(2026, 5, 2), "ojek", now, now, null))

        val search = dao.observeByPeriodAndQuery("p1", "Makan").first()
        assertEquals(1, search.size)
        assertEquals("t1", search.first().id)

        dao.softDelete("t1", Instant.now())
        val remaining = dao.observeByPeriod("p1").first()
        assertEquals(1, remaining.size)
        assertEquals("t2", remaining.first().id)
    }
}
