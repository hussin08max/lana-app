import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { DonationsService } from './donations.service';
import { CreateDonationDto } from './dto/create-donation.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@Controller('donations')
export class DonationsController {
  constructor(private readonly donationsService: DonationsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(@Body() dto: CreateDonationDto, @CurrentUser() user: any) {
    return this.donationsService.create(dto, user.sub);
  }

  @Get('my-donations')
  @UseGuards(JwtAuthGuard)
  async myDonations(@CurrentUser() user: any) {
    return this.donationsService.findForUser(user.sub);
  }

  @Get('case/:caseId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.AGENT)
  async donationsForCase(@Param('caseId') caseId: string) {
    return this.donationsService.findForCase(caseId);
  }
}

