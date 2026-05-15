package com.natasaku.app.data.local.mapper

import com.natasaku.app.data.local.entity.BudgetPeriodEntity
import com.natasaku.app.data.local.entity.ExpenseTransactionEntity
import com.natasaku.app.domain.model.BudgetPeriod
import com.natasaku.app.domain.model.ExpenseTransaction

fun BudgetPeriodEntity.toDomain() = BudgetPeriod(id, name, startDate, endDate, isActive, createdAt, updatedAt)
fun BudgetPeriod.toEntity() = BudgetPeriodEntity(id, name, startDate, endDate, isActive, createdAt, updatedAt)

fun ExpenseTransactionEntity.toDomain() = ExpenseTransaction(id, periodId, amount, category, date, note, createdAt, updatedAt, deletedAt)
fun ExpenseTransaction.toEntity() = ExpenseTransactionEntity(id, periodId, amount, category, date, note, createdAt, updatedAt, deletedAt)
