import 'dart:io';
import '../models/certification.dart';

class CertificationService {
  
  // 인증서류 목록 조회
  Future<List<Certification>> getCertifications({String? freelancerId}) async {
    try {
      // TODO: 실제 API 호출 구현
      await Future.delayed(const Duration(seconds: 1));
      
      // 샘플 데이터
      return [
        Certification(
          id: 'cert_1',
          freelancerId: freelancerId ?? 'freelancer_1',
          title: '보육교사 2급 자격증',
          description: '보육교사 2급 자격증입니다.',
          type: CertificationType.license,
          status: CertificationStatus.approved,
          fileUrls: ['https://example.com/cert1.pdf'],
          issuer: '한국보육진흥원',
          issueDate: DateTime(2020, 3, 15),
          expiryDate: DateTime(2025, 3, 14),
          licenseNumber: '20-보육-1234',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 25)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        Certification(
          id: 'cert_2',
          freelancerId: freelancerId ?? 'freelancer_1',
          title: '간병인 교육 수료증',
          description: '전문 간병인 교육과정을 수료했습니다.',
          type: CertificationType.certificate,
          status: CertificationStatus.approved,
          fileUrls: ['https://example.com/cert2.pdf'],
          issuer: '대한간병협회',
          issueDate: DateTime(2021, 8, 20),
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 15)),
          reviewedAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        Certification(
          id: 'cert_3',
          freelancerId: freelancerId ?? 'freelancer_1',
          title: '대학교 졸업증명서',
          description: '아동학과 학사 졸업',
          type: CertificationType.education,
          status: CertificationStatus.pending,
          fileUrls: ['https://example.com/cert3.pdf'],
          issuer: 'OO대학교',
          issueDate: DateTime(2018, 2, 28),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Certification(
          id: 'cert_4',
          freelancerId: freelancerId ?? 'freelancer_1',
          title: '돌봄 포트폴리오',
          description: '지난 3년간의 돌봄 서비스 사례들',
          type: CertificationType.portfolio,
          status: CertificationStatus.rejected,
          fileUrls: ['https://example.com/portfolio1.pdf', 'https://example.com/portfolio2.pdf'],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 8)),
          reviewNotes: '포트폴리오 내용이 부족합니다. 더 자세한 사례를 추가해주세요.',
          reviewedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  // 인증서류 상세 조회
  Future<Certification?> getCertification(String certificationId) async {
    try {
      // TODO: 실제 API 호출 구현
      await Future.delayed(const Duration(milliseconds: 500));
      
      final certifications = await getCertifications();
      return certifications.firstWhere(
        (cert) => cert.id == certificationId,
      );
    } catch (e) {
      return null;
    }
  }

  // 인증서류 등록
  Future<Map<String, dynamic>> createCertification({
    required String freelancerId,
    required String title,
    required String description,
    required CertificationType type,
    required List<String> fileUrls,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? licenseNumber,
  }) async {
    try {
      // TODO: 실제 API 호출 구현
      await Future.delayed(const Duration(seconds: 2));
      
      final certification = Certification(
        id: 'cert_${DateTime.now().millisecondsSinceEpoch}',
        freelancerId: freelancerId,
        title: title,
        description: description,
        type: type,
        status: CertificationStatus.pending,
        fileUrls: fileUrls,
        issuer: issuer,
        issueDate: issueDate,
        expiryDate: expiryDate,
        licenseNumber: licenseNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return {
        'success': true,
        'certification': certification,
        'message': '인증서류가 등록되었습니다. 검토까지 1-2일 소요됩니다.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': '인증서류 등록에 실패했습니다: $e'
      };
    }
  }

  // 인증서류 수정
  Future<Map<String, dynamic>> updateCertification({
    required String certificationId,
    String? title,
    String? description,
    CertificationType? type,
    List<String>? fileUrls,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? licenseNumber,
  }) async {
    try {
      // TODO: 실제 API 호출 구현
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'success': true,
        'message': '인증서류가 수정되었습니다.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': '인증서류 수정에 실패했습니다: $e'
      };
    }
  }

  // 인증서류 삭제
  Future<Map<String, dynamic>> deleteCertification(String certificationId) async {
    try {
      // TODO: 실제 API 호출 구현
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'success': true,
        'message': '인증서류가 삭제되었습니다.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': '인증서류 삭제에 실패했습니다: $e'
      };
    }
  }

  // 파일 업로드
  Future<FileUploadResult> uploadFile(File file) async {
    try {
      // TODO: 실제 파일 업로드 구현
      await Future.delayed(const Duration(seconds: 2));
      
      // 파일 크기 체크 (10MB 제한)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return FileUploadResult.failure('파일 크기는 10MB 이하여야 합니다.');
      }
      
      // 파일 확장자 체크
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
      
      if (!allowedExtensions.contains(extension)) {
        return FileUploadResult.failure('지원하지 않는 파일 형식입니다.');
      }
      
      // 성공적인 업로드 시뮬레이션
      final fileUrl = 'https://example.com/uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      return FileUploadResult.success(
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (e) {
      return FileUploadResult.failure('파일 업로드에 실패했습니다: $e');
    }
  }

  // 다중 파일 업로드
  Future<List<FileUploadResult>> uploadMultipleFiles(List<File> files) async {
    final results = <FileUploadResult>[];
    
    for (final file in files) {
      final result = await uploadFile(file);
      results.add(result);
    }
    
    return results;
  }

  // 파일 삭제
  Future<Map<String, dynamic>> deleteFile(String fileUrl) async {
    try {
      // TODO: 실제 파일 삭제 구현
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'success': true,
        'message': '파일이 삭제되었습니다.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': '파일 삭제에 실패했습니다: $e'
      };
    }
  }

  // 인증서류 통계
  Future<Map<String, int>> getCertificationStats({String? freelancerId}) async {
    try {
      // TODO: 실제 API 호출 구현
      await Future.delayed(const Duration(milliseconds: 500));
      
      final certifications = await getCertifications(freelancerId: freelancerId);
      
      final stats = <String, int>{
        'total': certifications.length,
        'approved': certifications.where((c) => c.status == CertificationStatus.approved).length,
        'pending': certifications.where((c) => c.status == CertificationStatus.pending).length,
        'rejected': certifications.where((c) => c.status == CertificationStatus.rejected).length,
        'expired': certifications.where((c) => c.status == CertificationStatus.expired).length,
        'expiring_soon': certifications.where((c) => c.isExpiring).length,
      };
      
      return stats;
    } catch (e) {
      return {};
    }
  }

  // 만료 예정 인증서류 조회
  Future<List<Certification>> getExpiringCertifications({String? freelancerId}) async {
    try {
      final certifications = await getCertifications(freelancerId: freelancerId);
      return certifications.where((cert) => cert.isExpiring).toList();
    } catch (e) {
      return [];
    }
  }
}
