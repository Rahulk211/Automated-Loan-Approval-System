import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sbs

df = pd.read_csv("E:\Loan_Approval_System\loanapprovalsystem\src\main\python\loan_data.csv")

sbs.set_style("whitegrid")

# Distribution of Loan Amount
plt.figure(figsize=(8,5))
sbs.histplot(df['loan_amnt'], bins = 30,kde = True, color = 'blue')
plt.title('Loan Amount Distribution')
plt.xlabel('Loan Amount')
plt.ylabel('Frequency')
plt.show()

# Credit Score vs Loan Status
plt.figure(figsize=(8,5))
sbs.boxplot(x=df['loan_status'], y=df['credit_score'], palette = 'coolwarm')
plt.title("Credit Score vs Loan Status")
plt.xlabel("Loan Status (0 = Rejected, 1 = Approved)")
plt.ylabel("Credit Score")
plt.show()

# Loan Approval Rate by Loan Intent
plt.figure(figsize=(8, 5))
intent_approval = df.groupby('loan_intent')['loan_status'].mean().sort_values()
sbs.barplot(x=intent_approval.index, y=intent_approval.values, palette='viridis')
plt.title("Loan Approval Rate by Loan Intent")
plt.xlabel("Loan Intent")
plt.ylabel("Approval Rate")
plt.xticks(rotation=45)
plt.show()

# Correlation Heatmap
plt.figure(figsize=(10, 6))
corr = df.corr()
sbs.heatmap(corr, annot=True, cmap='coolwarm', fmt='.2f', linewidths=0.5)
plt.title("Feature Correlation Heatmap")
plt.show()
