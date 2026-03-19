import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDonationDto } from './dto/create-donation.dto';
import { CaseStatus, DonationStatus } from '@prisma/client';

@Injectable()
export class DonationsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateDonationDto, userId: string) {
    const { caseId, amount } = dto;

    const targetCase = await this.prisma.case.findUnique({
      where: { id: caseId },
      select: { id: true, status: true },
    });

    if (!targetCase || targetCase.status !== CaseStatus.OPEN) {
      throw new BadRequestException('Case is not available for donation');
    }

    return this.prisma.donation.create({
      data: {
        amount,
        status: DonationStatus.PENDING,
        caseId,
        userId,
      },
    });
  }

  async findForUser(userId: string) {
    return this.prisma.donation.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        case: {
          select: {
            id: true,
            title: true,
            status: true,
            location: true,
          },
        },
      },
    });
  }

  async findForCase(caseId: string) {
    return this.prisma.donation.findMany({
      where: { caseId },
      orderBy: { createdAt: 'desc' },
    });
  }
}

