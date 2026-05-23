const assert = require('assert');
const budgeting = require('../../main/assets/budgeting-core.js');

function approx(actual, expected, tolerance = 0.02) {
  assert.ok(
    Math.abs(actual - expected) <= tolerance,
    `expected ${actual} to be within ${tolerance} of ${expected}`,
  );
}

const {
  calculateRemainingDays,
  calculateDailySafeBudget,
  calculateTodayBudgetUsage,
  getDailyBudgetStatus,
  getPeriodFundStatus,
  calculateTomorrowSafeBudget,
  calculateTodayAllowanceFromCurrentFund,
  simulateTransactionImpact,
  predictEndingBalance,
  predictFundRunoutDate,
  formatRupiah,
} = budgeting;

assert.strictEqual(
  calculateRemainingDays('2026-05-11', '2026-05-25'),
  15,
  'remaining days includes today',
);

assert.strictEqual(
  calculateRemainingDays('2026-05-26', '2026-05-25'),
  0,
  'remaining days never becomes negative',
);

approx(calculateDailySafeBudget(1_100_000, 15), 73_333.333);
assert.strictEqual(calculateDailySafeBudget(1_100_000, 0), 0);

assert.strictEqual(getDailyBudgetStatus({ dailyExpense: 75_000, dailySafeBudget: 73_333.33 }).code, 'SLIGHTLY_OVER');
assert.strictEqual(getDailyBudgetStatus({ dailyExpense: 0, dailySafeBudget: 73_333.33 }).code, 'NO_EXPENSE');
assert.strictEqual(getDailyBudgetStatus({ dailyExpense: 40_000, dailySafeBudget: 73_333.33 }).code, 'SAFE');
assert.strictEqual(getDailyBudgetStatus({ dailyExpense: 70_000, dailySafeBudget: 73_333.33 }).code, 'NEAR_LIMIT');
assert.strictEqual(getDailyBudgetStatus({ dailyExpense: 100_000, dailySafeBudget: 73_333.33 }).code, 'OVER_BUDGET');

const usage = calculateTodayBudgetUsage({ todayExpense: 75_000, dailySafeBudget: 73_333.33 });
approx(usage.usagePercentage, 102.27);
approx(usage.overBudgetAmount, 1_666.67);
assert.strictEqual(usage.remainingTodayBudget, 0);

assert.strictEqual(getPeriodFundStatus({ currentRemainingFund: 0, remainingDays: 15, dailySafeBudget: 0 }).code, 'EMPTY');
assert.strictEqual(getPeriodFundStatus({ currentRemainingFund: 300_000, remainingDays: 15, dailySafeBudget: 20_000 }).code, 'CRITICAL');
assert.strictEqual(getPeriodFundStatus({ currentRemainingFund: 600_000, remainingDays: 15, dailySafeBudget: 40_000 }).code, 'WATCH');
assert.strictEqual(getPeriodFundStatus({ currentRemainingFund: 1_100_000, remainingDays: 15, dailySafeBudget: 73_333.33 }).code, 'SAFE');
assert.strictEqual(getPeriodFundStatus({ currentRemainingFund: 1_100_000, remainingDays: 0, dailySafeBudget: 0 }).code, 'PERIOD_ENDED');

approx(calculateTomorrowSafeBudget({ currentRemainingFund: 1_100_000, todayExpense: 75_000, todayIncome: 0, remainingDays: 15 }), 73_214.285);

const simulated = simulateTransactionImpact({
  transactionAmount: 100_000,
  transactionType: 'Pengeluaran',
  currentRemainingFund: 1_100_000,
  todayExpense: 75_000,
  todayIncome: 0,
  remainingDays: 15,
  dailySafeBudget: 73_333.33,
});
assert.strictEqual(simulated.projectedDailyStatus.code, 'OVER_BUDGET');
approx(simulated.projectedUsagePercentage, 238.64);
approx(simulated.projectedTomorrowSafeBudget, 71_428.57);

approx(predictEndingBalance({
  initialFlexibleFund: 1_500_000,
  totalIncome: 0,
  totalExpenseSoFar: 400_000,
  daysElapsed: 5,
  totalPeriodDays: 20,
}), -100_000);

assert.strictEqual(
  predictFundRunoutDate({
    currentRemainingFund: 150_000,
    averageDailyExpense: 60_000,
    today: '2026-05-11',
    periodEnd: '2026-05-25',
  }),
  '2026-05-13',
);

assert.strictEqual(formatRupiah(73_333.33), 'Rp 73.333,33');

const dailyBeforeExpense = calculateDailySafeBudget(1_100_000, 15);
const dailyAfterExpense = calculateDailySafeBudget(1_100_000 - 75_000, 15);
approx(dailyBeforeExpense, 73_333.33);
approx(dailyAfterExpense, 68_333.33);

const todayAllowanceSnapshot = calculateTodayAllowanceFromCurrentFund({
  currentRemainingFund: 1_025_000,
  todayExpense: 75_000,
  todayIncome: 0,
  remainingDays: 15,
});
approx(todayAllowanceSnapshot.openingFundToday, 1_100_000);
approx(todayAllowanceSnapshot.dailySafeBudgetToday, 73_333.33);
approx(todayAllowanceSnapshot.currentRebalancedDailyBudget, 68_333.33);

console.log('budgeting-core tests passed');
