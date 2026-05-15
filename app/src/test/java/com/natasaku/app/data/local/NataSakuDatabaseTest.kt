package com.natasaku.app.data.local

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import com.natasaku.app.data.local.database.NataSakuDatabase
import com.natasaku.app.data.local.entity.BudgetPeriodEntity
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
class NataSakuDatabaseTest {
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
    fun activePeriod_canBeStoredAndObserved() = runBlocking {
        val now = Instant.now()
        db.budgetPeriodDao().upsert(BudgetPeriodEntity("p1", "Mei", LocalDate.of(2026, 5, 1), LocalDate.of(2026, 5, 31), true, now, now))
        val active = db.budgetPeriodDao().observeActivePeriod().first()
        assertEquals("p1", active?.id)
    }
}
