import sys

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    content = f.read()

start_idx = content.find('Widget _buildWalletSelector')
end_idx = content.find('Widget _buildSaveButton()')

if start_idx != -1 and end_idx != -1:
    new_method = '''Widget _buildWalletSelector(List<Wallet> wallets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WALLET',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        Builder(builder: (context) {
            if (wallets.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131929),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'No wallets found.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final w = wallets[i];
                final isSelected = w.id == _selectedWalletId;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedWalletId = w.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131929),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet,
                              color: Color(0xFF00E5FF), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                w.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\ \',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF00E5FF)),
                      ],
                    ),
                  ),
                );
              },
            );
        }),
      ],
    );
  }

  '''
    content = content[:start_idx] + new_method + content[end_idx:]
    
with open(sys.argv[1], 'w', encoding='utf-8') as f:
    f.write(content)
