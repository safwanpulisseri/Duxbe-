import 'package:duxbe/shared/shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_platform_provider.g.dart';

@Riverpod(keepAlive: true)
IPdfPlatform pdf(PdfRef ref) => IPdfPlatform();
