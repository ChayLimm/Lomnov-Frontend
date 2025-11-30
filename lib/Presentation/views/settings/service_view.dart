import 'package:flutter/material.dart';

class ServiceView extends StatelessWidget {
  const ServiceView({Key? key}) : super(key: key);

  static const routeName = '/services';

  final List<Map<String, String>> _services = const [
    {'title': 'Electricity', 'subtitle1': 'Quantity', 'subtitle2': 'Price'},
    {'title': 'Water', 'subtitle1': 'Quantity', 'subtitle2': 'Price'},
    {'title': 'Parking Fee', 'subtitle1': 'Quantity', 'subtitle2': 'Price'},
    {'title': 'Hygiene Fee', 'subtitle1': 'Quantity', 'subtitle2': 'Price'},
    {'title': 'Internet Fee', 'subtitle1': 'Quantity', 'subtitle2': 'Price'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Services',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: open add service flow
              },
              child: const Text('Add Service', style: TextStyle(color: Colors.black87)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Set up your price charge here', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: _services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _services[index];
                  return _ServiceCard(
                    title: item['title']!,
                    subtitleLeft: item['subtitle1']!,
                    subtitleRight: item['subtitle2']!,
                    onTap: () {
                      // TODO: navigate to service detail/edit
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitleLeft;
  final String subtitleRight;
  final VoidCallback? onTap;

  const _ServiceCard({
    Key? key,
    required this.title,
    required this.subtitleLeft,
    required this.subtitleRight,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inbox_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(subtitleLeft, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(width: 12),
                        Text(subtitleRight, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
