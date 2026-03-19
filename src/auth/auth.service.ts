import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { UserRole } from '@prisma/client';
import { VerifyOtpDto } from './dto/verify-otp.dto';

const MOCK_OTP = '1234';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async sendOtp(phone: string): Promise<{ success: boolean; otp: string }> {
    // في هذه المرحلة: Mock فقط - نفترض إرسال SMS ونطبع OTP
    // في الإنتاج سيتم الاندماج مع مزود SMS حقيقي.
    // eslint-disable-next-line no-console
    console.log(`Sending OTP ${MOCK_OTP} to phone ${phone}`);

    return { success: true, otp: MOCK_OTP };
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<{ accessToken: string }> {
    const { phone, otp } = dto;

    if (otp !== MOCK_OTP) {
      throw new UnauthorizedException('Invalid OTP');
    }

    const user = await this.prisma.user.upsert({
      where: { phone },
      update: {
        verified: true,
      },
      create: {
        phone,
        name: phone,
        role: UserRole.DONOR,
        verified: true,
      },
    });

    const payload = {
      sub: user.id,
      phone: user.phone,
      role: user.role,
      name: user.name,
    };

    const accessToken = await this.jwtService.signAsync(payload);

    return { accessToken };
  }
}

