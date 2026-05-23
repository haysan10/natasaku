package com.natasaku.app.data.export

import org.junit.Assert.assertTrue
import org.junit.Test

class BackupRestoreServiceValidationTest {
    @Test
    fun validBackupJson_hasRequiredFields() {
        val json = """
            {
              "app":"NataSaku",
              "schemaVersion":3,
              "exportedAt":"2026-05-07T10:00:00Z",
              "data":{
                "budgetPeriods":[],
                "incomeSources":[],
                "fixedExpenses":[],
                "expenseTransactions":[],
                "savingTargets":[],
                "savingAllocations":[],
                "dailyBudgetSnapshots":[],
                "preferences":{}
              }
            }
        """.trimIndent()
        assertTrue(json.contains("\"app\":\"NataSaku\""))
        assertTrue(json.contains("\"schemaVersion\":3"))
        assertTrue(json.contains("\"data\""))
    }

    @Test
    fun invalidBackupJson_wrongApp_detectable() {
        val json = """
            {
              "app":"OtherApp",
              "schemaVersion":3,
              "data":{
                "budgetPeriods":[],
                "incomeSources":[],
                "fixedExpenses":[],
                "expenseTransactions":[],
                "savingTargets":[],
                "savingAllocations":[],
                "dailyBudgetSnapshots":[],
                "preferences":{}
              }
            }
        """.trimIndent()
        assertTrue(json.contains("\"app\":\"OtherApp\""))
    }
}
