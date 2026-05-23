(function (root, factory) {
    const api = factory();
    if (typeof module === 'object' && module.exports) {
        module.exports = api;
    }
    root.NataSakuBudgeting = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
    const DAY_MS = 86400000;

    const dailyStatusLabels = {
        NO_EXPENSE: 'Belum Ada Pengeluaran',
        SAFE: 'Aman',
        NEAR_LIMIT: 'Mendekati Batas',
        SLIGHTLY_OVER: 'Melebihi Sedikit',
        OVER_BUDGET: 'Boros',
    };

    const periodStatusLabels = {
        SAFE: 'Aman',
        WATCH: 'Waspada',
        CRITICAL: 'Kritis',
        EMPTY: 'Dana Habis',
        PERIOD_ENDED: 'Periode Selesai',
    };

    function toNumber(value) {
        const number = Number(value);
        return Number.isFinite(number) ? number : 0;
    }

    function clampMoney(value) {
        return Math.max(0, toNumber(value));
    }

    function parseDate(value) {
        if (value instanceof Date && !Number.isNaN(value.getTime())) {
            return new Date(value.getFullYear(), value.getMonth(), value.getDate());
        }

        if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value)) {
            const [year, month, day] = value.split('-').map(Number);
            return new Date(year, month - 1, day);
        }

        const parsed = new Date(value);
        if (!Number.isNaN(parsed.getTime())) {
            return new Date(parsed.getFullYear(), parsed.getMonth(), parsed.getDate());
        }

        return new Date();
    }

    function formatDateKey(value) {
        const date = parseDate(value);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    function calculateRemainingDays(today, periodEnd) {
        const start = parseDate(today);
        const end = parseDate(periodEnd);
        const diff = Math.floor((end - start) / DAY_MS) + 1;
        return Math.max(diff, 0);
    }

    function calculateDailySafeBudget(currentRemainingFund, remainingDays) {
        const days = Math.max(0, Math.floor(toNumber(remainingDays)));
        if (days <= 0) return 0;
        return clampMoney(currentRemainingFund) / days;
    }

    function calculateTodayAllowanceFromCurrentFund({
        currentRemainingFund,
        todayExpense = 0,
        todayIncome = 0,
        remainingDays,
    }) {
        const openingFundToday = toNumber(currentRemainingFund) + clampMoney(todayExpense) - clampMoney(todayIncome);
        return {
            openingFundToday,
            dailySafeBudgetToday: calculateDailySafeBudget(openingFundToday, remainingDays),
            currentRebalancedDailyBudget: calculateDailySafeBudget(currentRemainingFund, remainingDays),
        };
    }

    function calculateTodayBudgetUsage({ todayExpense, dailySafeBudget }) {
        const expense = clampMoney(todayExpense);
        const budget = clampMoney(dailySafeBudget);
        const usagePercentage = budget > 0 ? (expense / budget) * 100 : (expense > 0 ? 100 : 0);
        return {
            usagePercentage,
            remainingTodayBudget: Math.max(budget - expense, 0),
            overBudgetAmount: Math.max(expense - budget, 0),
            difference: expense <= budget ? budget - expense : expense - budget,
        };
    }

    function getDailyBudgetStatus({ dailyExpense, dailySafeBudget }) {
        const expense = clampMoney(dailyExpense);
        const budget = clampMoney(dailySafeBudget);
        const usage = calculateTodayBudgetUsage({ todayExpense: expense, dailySafeBudget: budget });
        let code = 'NO_EXPENSE';

        if (expense === 0) {
            code = 'NO_EXPENSE';
        } else if (budget <= 0) {
            code = 'OVER_BUDGET';
        } else if (usage.usagePercentage <= 70) {
            code = 'SAFE';
        } else if (usage.usagePercentage <= 100) {
            code = 'NEAR_LIMIT';
        } else if (usage.usagePercentage <= 120) {
            code = 'SLIGHTLY_OVER';
        } else {
            code = 'OVER_BUDGET';
        }

        return {
            code,
            status: dailyStatusLabels[code],
            label: dailyStatusLabels[code],
            type: code === 'NO_EXPENSE' ? 'neutral' : (code === 'SAFE' ? 'safe' : (code === 'NEAR_LIMIT' ? 'watch' : 'warning')),
            difference: usage.difference,
            usagePercentage: usage.usagePercentage,
            remainingTodayBudget: usage.remainingTodayBudget,
            overBudgetAmount: usage.overBudgetAmount,
        };
    }

    function getPeriodFundStatus({
        currentRemainingFund,
        remainingDays,
        dailySafeBudget,
        criticalDailyBudgetThreshold = 25000,
        watchDailyBudgetThreshold = 50000,
    }) {
        const fund = toNumber(currentRemainingFund);
        const days = Math.max(0, Math.floor(toNumber(remainingDays)));
        const safeBudget = clampMoney(dailySafeBudget);

        let code = 'SAFE';
        if (days <= 0) code = 'PERIOD_ENDED';
        else if (fund <= 0) code = 'EMPTY';
        else if (safeBudget < criticalDailyBudgetThreshold) code = 'CRITICAL';
        else if (safeBudget < watchDailyBudgetThreshold) code = 'WATCH';
        else code = 'SAFE';

        return {
            code,
            status: periodStatusLabels[code],
            label: periodStatusLabels[code],
            type: code === 'SAFE' ? 'safe' : (code === 'WATCH' ? 'watch' : 'warning'),
        };
    }

    function calculateTomorrowSafeBudget({
        currentRemainingFund,
        todayExpense = 0,
        todayIncome = 0,
        remainingDays,
    }) {
        const daysAfterToday = Math.max(0, Math.floor(toNumber(remainingDays)) - 1);
        if (daysAfterToday <= 0) return 0;
        const projectedFund = clampMoney(toNumber(currentRemainingFund) + toNumber(todayIncome) - toNumber(todayExpense));
        return projectedFund / daysAfterToday;
    }

    function simulateTransactionImpact({
        transactionAmount,
        transactionType,
        currentRemainingFund,
        todayExpense,
        todayIncome,
        remainingDays,
        dailySafeBudget,
    }) {
        const amount = clampMoney(transactionAmount);
        const isIncome = String(transactionType || '').toLowerCase().includes('pemasukan') ||
            String(transactionType || '').toLowerCase().includes('income');
        const projectedTodayExpense = clampMoney(todayExpense) + (isIncome ? 0 : amount);
        const projectedTodayIncome = clampMoney(todayIncome) + (isIncome ? amount : 0);
        const projectedRemainingFund = toNumber(currentRemainingFund) + (isIncome ? amount : -amount);
        const projectedDailyStatus = getDailyBudgetStatus({
            dailyExpense: projectedTodayExpense,
            dailySafeBudget,
        });
        const projectedTomorrowSafeBudget = calculateTomorrowSafeBudget({
            currentRemainingFund: projectedRemainingFund,
            todayExpense: 0,
            todayIncome: 0,
            remainingDays,
        });

        let recommendationMessage = 'Transaksi ini masih terlihat aman untuk ritme budgetmu.';
        if (isIncome) {
            recommendationMessage = 'Pemasukan ini akan menambah ruang dana fleksibelmu.';
        } else if (projectedDailyStatus.code === 'NEAR_LIMIT') {
            recommendationMessage = 'Transaksi ini membuatmu mendekati batas aman hari ini.';
        } else if (projectedDailyStatus.code === 'SLIGHTLY_OVER') {
            recommendationMessage = `Transaksi ini melewati batas aman sebesar ${formatRupiah(projectedDailyStatus.overBudgetAmount)}.`;
        } else if (projectedDailyStatus.code === 'OVER_BUDGET') {
            recommendationMessage = 'Transaksi ini membuat pengeluaran hari ini jauh melewati batas aman.';
        }

        return {
            projectedTodayExpense,
            projectedTodayIncome,
            projectedRemainingFund,
            projectedDailyStatus,
            projectedUsagePercentage: projectedDailyStatus.usagePercentage,
            projectedTodayDifference: projectedDailyStatus.difference,
            projectedTomorrowSafeBudget,
            recommendationMessage,
        };
    }

    function predictEndingBalance({
        initialFlexibleFund,
        totalIncome,
        totalExpenseSoFar,
        daysElapsed,
        totalPeriodDays,
    }) {
        const elapsed = Math.max(1, Math.floor(toNumber(daysElapsed)));
        const periodDays = Math.max(elapsed, Math.floor(toNumber(totalPeriodDays)));
        const averageDailyExpense = clampMoney(totalExpenseSoFar) / elapsed;
        const projectedTotalExpense = averageDailyExpense * periodDays;
        return toNumber(initialFlexibleFund) + toNumber(totalIncome) - projectedTotalExpense;
    }

    function predictFundRunoutDate({
        currentRemainingFund,
        averageDailyExpense,
        today,
        periodEnd,
    }) {
        const fund = toNumber(currentRemainingFund);
        const dailyExpense = clampMoney(averageDailyExpense);
        if (fund > 0 && dailyExpense <= 0) return null;
        if (fund <= 0) return formatDateKey(today);

        const daysUntilRunout = Math.max(0, Math.ceil(fund / dailyExpense) - 1);
        const runout = parseDate(today);
        runout.setDate(runout.getDate() + daysUntilRunout);
        const end = parseDate(periodEnd);
        if (runout > end) return null;
        return formatDateKey(runout);
    }

    function formatRupiah(value) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
            maximumFractionDigits: 2,
        }).format(toNumber(value)).replace(/\u00a0/g, ' ');
    }

    return {
        dailyStatusLabels,
        periodStatusLabels,
        calculateRemainingDays,
        calculateDailySafeBudget,
        calculateTodayAllowanceFromCurrentFund,
        calculateTodayBudgetUsage,
        getDailyBudgetStatus,
        getPeriodFundStatus,
        calculateTomorrowSafeBudget,
        simulateTransactionImpact,
        predictEndingBalance,
        predictFundRunoutDate,
        formatRupiah,
    };
});
