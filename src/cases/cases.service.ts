import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCaseDto } from './dto/create-case.dto';
import { CaseStatus } from '@prisma/client';

@Injectable()
export class CasesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createCaseDto: CreateCaseDto, userId: string) {
    const { title, description, location, priority } = createCaseDto;

    return this.prisma.case.create({
      data: {
        title,
        description,
        location,
        priority: priority ?? 0,
        status: CaseStatus.OPEN,
        createdBy: userId,
      },
    });
  }

  async findAllOpen() {
    return this.prisma.case.findMany({
      where: { status: CaseStatus.OPEN },
      orderBy: { createdAt: 'desc' },
      include: {
        createdByUser: {
          select: {
            id: true,
            name: true,
          },
        },
      },
    });
  }

  async findOneWithRelations(id: string) {
    const found = await this.prisma.case.findUnique({
      where: { id },
      include: {
        createdByUser: {
          select: {
            id: true,
            name: true,
          },
        },
        donations: true,
        updates: true,
      },
    });

    if (!found) {
      throw new NotFoundException('Case not found');
    }

    return found;
  }
}

