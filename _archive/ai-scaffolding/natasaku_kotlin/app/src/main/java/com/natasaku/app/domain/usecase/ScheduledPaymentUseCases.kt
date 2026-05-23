package com.natasaku.app.domain.usecase

import com.natasaku.app.data.local.dao.ScheduledPaymentDao
import com.natasaku.app.data.local.entity.ScheduledPaymentEntity
import kotlinx.coroutines.flow.Flow

class CreateScheduledPaymentUseCase(
    private val dao: ScheduledPaymentDao,
) {
    suspend operator fun invoke(entity: ScheduledPaymentEntity): Long = dao.upsert(entity.copy(id = 0))
}

class UpdateScheduledPaymentUseCase(
    private val dao: ScheduledPaymentDao,
) {
    suspend operator fun invoke(entity: ScheduledPaymentEntity): Long = dao.upsert(entity)
}

class DeleteScheduledPaymentUseCase(
    private val dao: ScheduledPaymentDao,
) {
    suspend operator fun invoke(id: Long) {
        dao.softDelete(id)
    }
}

class GetAllScheduledPaymentsUseCase(
    private val dao: ScheduledPaymentDao,
) {
    operator fun invoke(): Flow<List<ScheduledPaymentEntity>> = dao.observeAll()
}
