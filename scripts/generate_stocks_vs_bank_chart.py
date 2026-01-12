
import matplotlib.pyplot as plt
import numpy as np

# Data Configuration
years = np.arange(0, 11) # 0 to 10 years
initial_investment = 10000

# Growth Rates
rate_bank = 0.004 # 0.4%
rate_stocks = 0.12 # 12.0%

# Calculate Curves
bank_values = initial_investment * (1 + rate_bank) ** years
stock_values = initial_investment * (1 + rate_stocks) ** years

# Style Configuration
plt.figure(figsize=(10, 8), dpi=300)
plt.style.use('default')

# Remove borders (spines)
for spine in plt.gca().spines.values():
    spine.set_visible(False)

# Colors
COLOR_BANK = '#50C878' # Emerald/growth green
COLOR_STOCKS = '#007AFF' # Investr Blue
COLOR_TEXT = '#333333'

# Plot Lines
plt.plot(years, stock_values, color=COLOR_STOCKS, linewidth=4, label='S&P 500 (~12%)')
plt.plot(years, bank_values, color=COLOR_BANK, linewidth=4, label='Savings (~0.4%)')

# Fill areas for "modern" look (optional, but adds to the alert tile style)
plt.fill_between(years, stock_values, bank_values, color=COLOR_STOCKS, alpha=0.1)
plt.fill_between(years, bank_values, initial_investment, color=COLOR_BANK, alpha=0.1)

# Annotations (End Values)
plt.text(10.2, stock_values[-1], f'${stock_values[-1]:,.0f}', color=COLOR_STOCKS, fontsize=16, fontweight='bold', va='center')
plt.text(10.2, bank_values[-1], f'${bank_values[-1]:,.0f}', color=COLOR_BANK, fontsize=16, fontweight='bold', va='center')

# Labels and Ticks
plt.title('Growth of $10,000 (10 Years)', fontsize=20, fontweight='bold', color=COLOR_TEXT, pad=20)
plt.xlabel('Years', fontsize=14, color=COLOR_TEXT)
plt.ylabel('Value', fontsize=14, color=COLOR_TEXT)

plt.xticks(years)
plt.gca().yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'${x:,.0f}'))
plt.grid(axis='y', linestyle='--', alpha=0.3)

# Legend
plt.legend(frameon=False, fontsize=12, loc='upper left')

# Adjust layout to prevent clipping
plt.tight_layout()

# Save
plt.savefig('assets/images/education/stocks_vs_bank_accurate.png', transparent=False, bbox_inches='tight')
